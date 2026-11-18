package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"slices"
	"strings"
	"time"
)

const tokenNameSep = " @ "

// managedName reports whether a Cloudflare token name belongs to a consumer:
// the bootstrap token uses the bare name, rotated ones add " @ <timestamp>".
func managedName(name, base string) bool {
	return name == base || strings.HasPrefix(name, base+tokenNameSep)
}

type ConsumerState struct {
	// ReloadedTokenID is the token every reload hook last succeeded with.
	ReloadedTokenID string    `json:"reloadedTokenId"`
	ReloadedAt      time.Time `json:"reloadedAt"`
}

type State struct {
	Consumers map[string]ConsumerState `json:"consumers"`
}

type Report struct {
	Rotated  []string
	Revoked  []string
	Warnings []string
}

type Rotator struct {
	Cfg            *Config
	CF             Cloudflare
	Secrets        SecretStore
	Reloaders      ReloaderFactory
	Notify         Notifier
	Now            func() time.Time
	DryRun         bool
	Force          map[string]bool // consumer name or "all"
	Only           map[string]bool // empty = every consumer
	RotatorTokenID string          // never revoked
	VerifyTimeout  time.Duration

	state     State
	tokenList []CFToken
}

func (r *Rotator) loadState(ctx context.Context) error {
	r.state = State{Consumers: map[string]ConsumerState{}}
	raw, err := r.Secrets.Get(ctx, r.Cfg.State)
	if errors.Is(err, ErrSecretNotFound) || (err == nil && strings.TrimSpace(raw) == "") {
		slog.Info("no rotator state yet, starting fresh", "ref", r.Cfg.State.String())
		return nil
	}
	if err != nil {
		return err
	}
	if err := json.Unmarshal([]byte(raw), &r.state); err != nil {
		return fmt.Errorf("parse state %s: %w", r.Cfg.State, err)
	}
	if r.state.Consumers == nil {
		r.state.Consumers = map[string]ConsumerState{}
	}
	return nil
}

func (r *Rotator) saveState(ctx context.Context) error {
	if r.DryRun {
		return nil
	}
	b, err := json.Marshal(r.state)
	if err != nil {
		return err
	}
	return r.Secrets.Set(ctx, r.Cfg.State, string(b))
}

// Run processes every enabled consumer, sends one summary notification and
// returns the joined errors.
func (r *Rotator) Run(ctx context.Context) error {
	if r.Now == nil {
		r.Now = time.Now
	}
	if r.VerifyTimeout == 0 {
		r.VerifyTimeout = 90 * time.Second
	}
	if err := r.loadState(ctx); err != nil {
		r.notifyFailure(ctx, []string{"load state: " + err.Error()})
		return err
	}

	var rep Report
	var errs []error
	var failures []string
	for _, c := range r.Cfg.Consumers {
		if c.Disabled || (len(r.Only) > 0 && !r.Only[c.Name]) {
			continue
		}
		log := slog.With("consumer", c.Name)
		if err := r.processConsumer(ctx, log, c, &rep); err != nil {
			log.Error("consumer failed", "err", err)
			errs = append(errs, fmt.Errorf("%s: %w", c.Name, err))
			failures = append(failures, fmt.Sprintf("%s: %v", c.Name, err))
		}
	}

	if len(failures) > 0 || len(rep.Warnings) > 0 {
		r.notifyFailure(ctx, append(failures, rep.Warnings...))
	}
	if len(rep.Rotated) > 0 || len(rep.Revoked) > 0 {
		var b strings.Builder
		if len(rep.Rotated) > 0 {
			fmt.Fprintf(&b, "Rotated: %s\n", strings.Join(rep.Rotated, ", "))
		}
		if len(rep.Revoked) > 0 {
			fmt.Fprintf(&b, "Revoked: %s\n", strings.Join(rep.Revoked, ", "))
		}
		r.Notify.Notify(ctx, r.title("Cloudflare tokens rotated"), "default", "key", b.String())
	}
	return errors.Join(errs...)
}

func (r *Rotator) title(s string) string {
	if r.DryRun {
		return "[dry-run] " + s
	}
	return s
}

func (r *Rotator) notifyFailure(ctx context.Context, lines []string) {
	r.Notify.Notify(ctx, r.title("Cloudflare token rotation needs attention"), "high", "warning",
		strings.Join(lines, "\n"))
}

func (r *Rotator) processConsumer(ctx context.Context, log *slog.Logger, c Consumer, rep *Report) error {
	now := r.Now()
	primary := c.Targets[0]

	// 1. Identify the current token from the source-of-truth secret.
	cur, err := r.Secrets.Get(ctx, primary)
	if errors.Is(err, ErrSecretNotFound) || (err == nil && cur == "") {
		return fmt.Errorf("no token at %s: create an account-owned token named %q and store it there (see README)", primary, c.TokenName)
	}
	if err != nil {
		return err
	}
	curID, err := r.CF.Verify(ctx, cur)
	if err != nil {
		return fmt.Errorf("current token at %s does not verify: %w", primary, err)
	}
	curTok, err := r.CF.GetToken(ctx, curID)
	if err != nil {
		return err
	}
	if !managedName(curTok.Name, c.TokenName) {
		return fmt.Errorf("token %s at %s is named %q; rename it to %q so old copies can be found and revoked",
			curID, primary, curTok.Name, c.TokenName)
	}
	log = log.With("token_id", curTok.ID)

	// 2. Rotate when the token is old or close to expiry.
	age := now.Sub(curTok.IssuedOn.Time)
	expiringSoon := !curTok.ExpiresOn.IsZero() && curTok.ExpiresOn.Sub(now) < r.Cfg.Rotation.Interval.D()
	rotated := false
	if r.Force["all"] || r.Force[c.Name] || age >= r.Cfg.Rotation.Interval.D() || expiringSoon {
		log.Info("rotating", "age", age.Round(time.Hour).String(), "expiring_soon", expiringSoon)
		if r.DryRun {
			log.Info("dry-run: would create a new token and distribute it")
		} else {
			newTok, err := r.issue(ctx, log, c, curTok, now)
			if err != nil {
				return err
			}
			cur, curTok, rotated = newTok.Value, newTok, true
			rep.Rotated = append(rep.Rotated, c.Name)
			log = log.With("token_id", curTok.ID)
		}
	}

	// 3. Make every other target hold the current value.
	changed := rotated
	for _, t := range c.Targets[1:] {
		v, err := r.Secrets.Get(ctx, t)
		if err != nil && !errors.Is(err, ErrSecretNotFound) {
			return err
		}
		if err == nil && v == cur {
			continue
		}
		changed = true
		log.Info("syncing target", "ref", t.String())
		if !r.DryRun {
			if err := r.Secrets.Set(ctx, t, cur); err != nil {
				return err
			}
		}
	}

	// 4. Reload consumers until they have all picked up the current token.
	cs, known := r.state.Consumers[c.Name]
	switch {
	case !known && !changed:
		// First run against an already-deployed token: assume it is live.
		log.Info("adopting current token without reloading")
		cs = ConsumerState{ReloadedTokenID: curTok.ID, ReloadedAt: now}
		r.state.Consumers[c.Name] = cs
		if err := r.saveState(ctx); err != nil {
			return err
		}
	case cs.ReloadedTokenID != curTok.ID || changed:
		if r.DryRun {
			log.Info("dry-run: would run reload hooks", "hooks", len(c.Reload))
			return nil
		}
		if err := r.reload(ctx, log, c, cur); err != nil {
			return err
		}
		cs = ConsumerState{ReloadedTokenID: curTok.ID, ReloadedAt: r.Now()}
		r.state.Consumers[c.Name] = cs
		if err := r.saveState(ctx); err != nil {
			return err
		}
	}

	// 5. Revoke older tokens once everything has run on the new one for
	// the grace period.
	if cs.ReloadedTokenID != curTok.ID || now.Before(cs.ReloadedAt.Add(r.Cfg.Rotation.Grace.D())) {
		return nil
	}
	return r.revokeOld(ctx, log, c, curTok, cs, rep)
}

// issue creates and verifies a clone of cur, then stores it at the primary
// target. On failure it deletes the new token so nothing dangles.
func (r *Rotator) issue(ctx context.Context, log *slog.Logger, c Consumer, cur *CFToken, now time.Time) (*CFToken, error) {
	var expires time.Time
	if r.Cfg.Rotation.Expiry.D() > 0 {
		expires = now.Add(r.Cfg.Rotation.Expiry.D())
	}
	name := c.TokenName + tokenNameSep + now.UTC().Format("2006-01-02T15:04Z")
	newTok, err := r.CF.CreateClone(ctx, cur, name, expires)
	if err != nil {
		return nil, fmt.Errorf("create token: %w", err)
	}
	if newTok.IssuedOn.IsZero() {
		newTok.IssuedOn = CFTime{now}
	}
	log.Info("created token", "new_token_id", newTok.ID, "name", name)

	cleanup := func(cause error) error {
		if derr := r.CF.DeleteToken(context.WithoutCancel(ctx), newTok.ID); derr != nil {
			return fmt.Errorf("%w (and deleting new token %s failed: %v)", cause, newTok.ID, derr)
		}
		return cause
	}

	// New tokens can take a few seconds to propagate.
	err = poll(ctx, r.VerifyTimeout, 3*time.Second, func() (bool, error) {
		id, err := r.CF.Verify(ctx, newTok.Value)
		if err == nil && id != newTok.ID {
			return false, fmt.Errorf("verify returned id %s, want %s", id, newTok.ID)
		}
		return err == nil, err
	})
	if err != nil {
		return nil, cleanup(fmt.Errorf("new token never verified: %w", err))
	}
	if err := r.Secrets.Set(ctx, c.Targets[0], newTok.Value); err != nil {
		return nil, cleanup(err)
	}
	return newTok, nil
}

func (r *Rotator) reload(ctx context.Context, log *slog.Logger, c Consumer, token string) error {
	for i, spec := range c.Reload {
		rl, err := r.Reloaders(ctx, spec)
		if err != nil {
			return fmt.Errorf("reload[%d] %s: %w", i, spec.Type, err)
		}
		log.Info("reloading", "hook", rl.Describe())
		if err := rl.Reload(ctx, token); err != nil {
			return fmt.Errorf("%s: %w", rl.Describe(), err)
		}
	}
	return nil
}

func (r *Rotator) revokeOld(ctx context.Context, log *slog.Logger, c Consumer, cur *CFToken, cs ConsumerState, rep *Report) error {
	if r.tokenList == nil {
		list, err := r.CF.ListTokens(ctx)
		if err != nil {
			return err
		}
		r.tokenList = list
	}
	cutoff := cs.ReloadedAt.Add(r.Cfg.Rotation.Settle.D())
	var errs []error
	for _, t := range r.tokenList {
		if t.ID == cur.ID || t.ID == r.RotatorTokenID || !managedName(t.Name, c.TokenName) {
			continue
		}
		if !t.LastUsedOn.IsZero() && t.LastUsedOn.After(cutoff) {
			msg := fmt.Sprintf("%s: old token %s (%q) was used at %s, after every consumer was reloaded; not revoking. Find what still holds it.",
				c.Name, t.ID, t.Name, t.LastUsedOn.UTC().Format(time.RFC3339))
			log.Warn(msg)
			rep.Warnings = append(rep.Warnings, msg)
			continue
		}
		log.Info("revoking", "old_token_id", t.ID, "name", t.Name)
		if r.DryRun {
			continue
		}
		if err := r.CF.DeleteToken(ctx, t.ID); err != nil {
			errs = append(errs, fmt.Errorf("revoke %s: %w", t.ID, err))
			continue
		}
		rep.Revoked = append(rep.Revoked, fmt.Sprintf("%s (%s)", c.Name, t.ID))
		r.tokenList = slices.DeleteFunc(r.tokenList, func(x CFToken) bool { return x.ID == t.ID })
	}
	return errors.Join(errs...)
}
