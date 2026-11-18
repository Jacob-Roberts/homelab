// cf-token-rotator issues fresh Cloudflare API tokens, distributes them
// through Infisical, reloads every consumer, and revokes the old tokens after
// a grace period. See README.md.
package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"log/slog"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"
)

func main() {
	slog.SetDefault(slog.New(slog.NewJSONHandler(os.Stderr, nil)))
	if err := run(); err != nil {
		slog.Error("run failed", "err", err)
		os.Exit(1)
	}
}

func envOrFile(name string) (string, error) {
	if v := os.Getenv(name); v != "" {
		return v, nil
	}
	if p := os.Getenv(name + "_FILE"); p != "" {
		b, err := os.ReadFile(p)
		return strings.TrimSpace(string(b)), err
	}
	return "", fmt.Errorf("%s or %s_FILE must be set", name, name)
}

func set(csv string) map[string]bool {
	m := map[string]bool{}
	for _, s := range strings.Split(csv, ",") {
		if s = strings.TrimSpace(s); s != "" {
			m[s] = true
		}
	}
	return m
}

func run() error {
	configPath := flag.String("config", "/etc/cf-token-rotator/config.yaml", "config file")
	dryRun := flag.Bool("dry-run", false, "log what would happen without changing anything")
	force := flag.String("force", "", "comma-separated consumers to rotate now regardless of age, or \"all\"")
	only := flag.String("only", "", "comma-separated consumers to process (default all)")
	validate := flag.Bool("validate", false, "only validate the config file")
	flag.Parse()

	cfg, err := LoadConfig(*configPath)
	if err != nil {
		return err
	}
	if *validate {
		fmt.Println("config OK")
		return nil
	}
	for name := range set(*only) {
		if !consumerExists(cfg, name) {
			return fmt.Errorf("-only: unknown consumer %q", name)
		}
	}
	for name := range set(*force) {
		if name != "all" && !consumerExists(cfg, name) {
			return fmt.Errorf("-force: unknown consumer %q", name)
		}
	}

	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()
	ctx, cancel := context.WithTimeout(ctx, 45*time.Minute)
	defer cancel()

	clientID, err := envOrFile("INFISICAL_CLIENT_ID")
	if err != nil {
		return err
	}
	clientSecret, err := envOrFile("INFISICAL_CLIENT_SECRET")
	if err != nil {
		return err
	}
	inf, err := NewInfisical(ctx, cfg.Infisical.SiteURL, cfg.Infisical.ProjectID, clientID, clientSecret)
	if err != nil {
		return err
	}

	var notifier Notifier = logNotifier{}
	if cfg.Ntfy.URL != nil {
		n := ntfyNotifier{}
		if n.url, err = inf.Get(ctx, *cfg.Ntfy.URL); err != nil {
			return fmt.Errorf("ntfy url: %w", err)
		}
		if cfg.Ntfy.Token != nil {
			if n.token, err = inf.Get(ctx, *cfg.Ntfy.Token); err != nil {
				return fmt.Errorf("ntfy token: %w", err)
			}
		}
		notifier = n
	}
	fail := func(err error) error {
		notifier.Notify(ctx, "Cloudflare token rotation needs attention", "high", "warning", err.Error())
		return err
	}

	accountID, err := inf.Get(ctx, cfg.Cloudflare.AccountID)
	if err != nil {
		return fail(fmt.Errorf("cloudflare account id: %w", err))
	}
	rotatorToken, err := inf.Get(ctx, cfg.Cloudflare.RotatorToken)
	if err != nil {
		return fail(fmt.Errorf("rotator token: %w", err))
	}
	cf := NewCloudflare(accountID, rotatorToken)
	rotatorID, err := cf.Verify(ctx, rotatorToken)
	if err != nil {
		return fail(fmt.Errorf("rotator token does not verify (it must be account-owned with Account API Tokens: Edit): %w", err))
	}
	if !curTokenExpiryOK(ctx, cf, rotatorID) {
		notifier.Notify(ctx, "Cloudflare rotator token expires soon", "high", "warning",
			"The rotator's own token expires within 30 days. Create a new one and update "+cfg.Cloudflare.RotatorToken.String())
	}

	r := &Rotator{
		Cfg: cfg, CF: cf, Secrets: inf, Reloaders: defaultReloaderFactory(inf), Notify: notifier,
		DryRun: *dryRun, Force: set(*force), Only: set(*only), RotatorTokenID: rotatorID,
	}
	err = r.Run(ctx)
	if err == nil {
		slog.Info("done", "dry_run", *dryRun)
	}
	return err
}

func consumerExists(cfg *Config, name string) bool {
	for _, c := range cfg.Consumers {
		if c.Name == name {
			return true
		}
	}
	return false
}

// curTokenExpiryOK warns before the hand-rotated rotator token lapses.
func curTokenExpiryOK(ctx context.Context, cf Cloudflare, id string) bool {
	t, err := cf.GetToken(ctx, id)
	if err != nil {
		slog.Warn("could not read rotator token details", "err", err)
		return !errors.Is(err, context.Canceled)
	}
	return t.ExpiresOn.IsZero() || time.Until(t.ExpiresOn.Time) > 30*24*time.Hour
}
