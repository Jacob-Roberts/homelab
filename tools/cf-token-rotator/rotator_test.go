package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"testing"
	"time"
)

// ---- fakes

type fakeCF struct {
	tokens  map[string]*CFToken // id -> token
	byValue map[string]string   // value -> id
	now     func() time.Time
	seq     int
	failVer bool
	deleted []string
}

func newFakeCF(now func() time.Time) *fakeCF {
	return &fakeCF{tokens: map[string]*CFToken{}, byValue: map[string]string{}, now: now}
}

func (f *fakeCF) add(name, value string, issued time.Time) *CFToken {
	f.seq++
	t := &CFToken{ID: fmt.Sprintf("tok%d", f.seq), Name: name, Status: "active", IssuedOn: CFTime{issued},
		Policies: []CFPolicy{{Effect: "allow", Resources: json.RawMessage(`{"com.cloudflare.api.account.zone.z1":"*"}`),
			PermissionGroups: []CFPermissionGroup{{ID: "dns-edit"}}}}}
	f.tokens[t.ID] = t
	f.byValue[value] = t.ID
	return t
}

func (f *fakeCF) Verify(_ context.Context, v string) (string, error) {
	id, ok := f.byValue[v]
	if !ok || f.tokens[id] == nil || f.failVer {
		return "", errors.New("invalid token")
	}
	return id, nil
}
func (f *fakeCF) GetToken(_ context.Context, id string) (*CFToken, error) {
	t, ok := f.tokens[id]
	if !ok {
		return nil, errors.New("not found")
	}
	c := *t
	return &c, nil
}
func (f *fakeCF) ListTokens(context.Context) ([]CFToken, error) {
	var out []CFToken
	for _, t := range f.tokens {
		out = append(out, *t)
	}
	return out, nil
}
func (f *fakeCF) CreateClone(_ context.Context, src *CFToken, name string, exp time.Time) (*CFToken, error) {
	val := fmt.Sprintf("value-%d", f.seq+1)
	t := f.add(name, val, f.now())
	t.Policies, t.ExpiresOn = src.Policies, CFTime{exp}
	c := *t
	c.Value = val
	return &c, nil
}
func (f *fakeCF) DeleteToken(_ context.Context, id string) error {
	delete(f.tokens, id)
	f.deleted = append(f.deleted, id)
	return nil
}

type fakeStore map[string]string

func (s fakeStore) Get(_ context.Context, r SecretRef) (string, error) {
	v, ok := s[r.String()]
	if !ok {
		return "", ErrSecretNotFound
	}
	return v, nil
}
func (s fakeStore) Set(_ context.Context, r SecretRef, v string) error { s[r.String()] = v; return nil }

type fakeReloader struct {
	calls *[]string
	fail  *bool
	desc  string
}

func (f fakeReloader) Describe() string { return f.desc }
func (f fakeReloader) Reload(_ context.Context, tok string) error {
	if *f.fail {
		return errors.New("boom")
	}
	*f.calls = append(*f.calls, f.desc+"="+tok)
	return nil
}

type nopNotifier struct{ msgs []string }

func (n *nopNotifier) Notify(_ context.Context, title, _, _, msg string) {
	n.msgs = append(n.msgs, title+": "+msg)
}

// ---- harness

type harness struct {
	t       *testing.T
	now     time.Time
	cf      *fakeCF
	store   fakeStore
	calls   []string
	fail    bool
	notes   *nopNotifier
	cfg     *Config
	primary SecretRef
	second  SecretRef
}

func newHarness(t *testing.T) *harness {
	h := &harness{t: t, now: time.Date(2026, 1, 1, 0, 0, 0, 0, time.UTC), store: fakeStore{}, notes: &nopNotifier{}}
	h.cf = newFakeCF(func() time.Time { return h.now })
	h.primary = SecretRef{"prod", "/pbj/traefik", "CF_DNS_API_TOKEN"}
	h.second = SecretRef{"prod", "/pbj/k8s", "COPY"}
	cfg := &Config{}
	cfg.Infisical.ProjectID = "p"
	cfg.Cloudflare.AccountID = SecretRef{"prod", "/global", "ACCT"}
	cfg.Cloudflare.RotatorToken = SecretRef{"prod", "/global", "ROT"}
	cfg.State = SecretRef{"prod", "/global/cf-token-rotator", "STATE"}
	cfg.Rotation.Interval = Duration(30 * 24 * time.Hour)
	cfg.Rotation.Grace = Duration(24 * time.Hour)
	cfg.Rotation.Settle = Duration(time.Hour)
	cfg.Rotation.Expiry = Duration(60 * 24 * time.Hour)
	cfg.Consumers = []Consumer{{
		Name: "traefik-pbj", TokenName: "homelab/traefik-pbj",
		Targets: []SecretRef{h.primary, h.second},
		Reload:  []ReloadSpec{{Type: "doco-cd"}},
	}}
	h.cfg = cfg
	return h
}

func (h *harness) run(dry bool, force ...string) error {
	f := map[string]bool{}
	for _, x := range force {
		f[x] = true
	}
	r := &Rotator{
		Cfg: h.cfg, CF: h.cf, Secrets: h.store, Notify: h.notes, Now: func() time.Time { return h.now },
		DryRun: dry, Force: f, VerifyTimeout: 50 * time.Millisecond, RotatorTokenID: "rotator",
		Reloaders: func(_ context.Context, s ReloadSpec) (Reloader, error) {
			return fakeReloader{calls: &h.calls, fail: &h.fail, desc: s.Type}, nil
		},
	}
	return r.Run(context.Background())
}

func (h *harness) state() State {
	var s State
	if err := json.Unmarshal([]byte(h.store[h.cfg.State.String()]), &s); err != nil {
		h.t.Fatalf("state: %v", err)
	}
	return s
}

func (h *harness) bootstrap() *CFToken {
	tok := h.cf.add("homelab/traefik-pbj", "initial", h.now.Add(-10*24*time.Hour))
	h.store[h.primary.String()] = "initial"
	h.store[h.second.String()] = "initial"
	return tok
}

// ---- tests

func TestAdoptsExistingTokenWithoutReload(t *testing.T) {
	h := newHarness(t)
	tok := h.bootstrap()
	if err := h.run(false); err != nil {
		t.Fatal(err)
	}
	if len(h.calls) != 0 {
		t.Fatalf("expected no reloads, got %v", h.calls)
	}
	if got := h.state().Consumers["traefik-pbj"].ReloadedTokenID; got != tok.ID {
		t.Fatalf("state reloadedTokenId = %q, want %q", got, tok.ID)
	}
}

func TestFullLifecycle(t *testing.T) {
	h := newHarness(t)
	old := h.bootstrap()
	must(t, h.run(false)) // adopt

	// 25 days later the token is 35 days old: rotate.
	h.now = h.now.Add(25 * 24 * time.Hour)
	must(t, h.run(false))
	newVal := h.store[h.primary.String()]
	if newVal == "initial" || h.store[h.second.String()] != newVal {
		t.Fatalf("targets not updated: %v", h.store)
	}
	if len(h.calls) != 1 || h.calls[0] != "doco-cd="+newVal {
		t.Fatalf("reload calls = %v", h.calls)
	}
	if _, ok := h.cf.tokens[old.ID]; !ok {
		t.Fatal("old token revoked before grace")
	}
	newID := h.cf.byValue[newVal]
	if !strings.HasPrefix(h.cf.tokens[newID].Name, "homelab/traefik-pbj @ ") {
		t.Fatalf("bad new name %q", h.cf.tokens[newID].Name)
	}
	if h.cf.tokens[newID].ExpiresOn.IsZero() {
		t.Fatal("new token has no expiry")
	}

	// 12h later: still in grace.
	h.now = h.now.Add(12 * time.Hour)
	must(t, h.run(false))
	if _, ok := h.cf.tokens[old.ID]; !ok {
		t.Fatal("old token revoked during grace")
	}

	// 25h after reload: revoke, and do not touch the current token.
	h.now = h.now.Add(13 * time.Hour)
	must(t, h.run(false))
	if _, ok := h.cf.tokens[old.ID]; ok {
		t.Fatal("old token not revoked after grace")
	}
	if _, ok := h.cf.tokens[newID]; !ok {
		t.Fatal("current token was revoked")
	}
	if len(h.calls) != 1 {
		t.Fatalf("unexpected extra reloads: %v", h.calls)
	}
}

func TestReloadFailureBlocksRevocationAndRetries(t *testing.T) {
	h := newHarness(t)
	old := h.bootstrap()
	must(t, h.run(false))

	h.fail = true
	if err := h.run(false, "traefik-pbj"); err == nil {
		t.Fatal("expected reload error")
	}
	if len(h.notes.msgs) == 0 || !strings.Contains(h.notes.msgs[0], "boom") {
		t.Fatalf("expected failure notification, got %v", h.notes.msgs)
	}

	// Days pass with reloads failing: the old token must survive.
	h.now = h.now.Add(5 * 24 * time.Hour)
	_ = h.run(false)
	if _, ok := h.cf.tokens[old.ID]; !ok {
		t.Fatal("old token revoked although reload never succeeded")
	}

	// Reload recovers; revocation waits a full grace from then.
	h.fail = false
	must(t, h.run(false))
	if len(h.calls) != 1 {
		t.Fatalf("expected one successful reload, got %v", h.calls)
	}
	if _, ok := h.cf.tokens[old.ID]; !ok {
		t.Fatal("old token revoked without grace after late reload")
	}
	h.now = h.now.Add(25 * time.Hour)
	must(t, h.run(false))
	if _, ok := h.cf.tokens[old.ID]; ok {
		t.Fatal("old token not revoked")
	}
}

func TestOldTokenStillInUseIsNotRevoked(t *testing.T) {
	h := newHarness(t)
	old := h.bootstrap()
	must(t, h.run(false))
	must(t, h.run(false, "traefik-pbj"))

	h.now = h.now.Add(25 * time.Hour)
	h.cf.tokens[old.ID].LastUsedOn = CFTime{h.now.Add(-time.Hour)} // used well after reload
	must(t, h.run(false))
	if _, ok := h.cf.tokens[old.ID]; !ok {
		t.Fatal("in-use token was revoked")
	}
	if len(h.notes.msgs) == 0 || !strings.Contains(strings.Join(h.notes.msgs, "\n"), "not revoking") {
		t.Fatalf("expected in-use warning, got %v", h.notes.msgs)
	}
}

func TestUnmanagedTokensAreNeverRevoked(t *testing.T) {
	h := newHarness(t)
	h.bootstrap()
	other := h.cf.add("homelab/traefik-pbj-backup", "x", h.now.Add(-100*24*time.Hour))
	// Named like a managed token, but it is the rotator's own ID.
	h.cf.tokens["rotator"] = &CFToken{ID: "rotator", Name: "homelab/traefik-pbj @ x", IssuedOn: CFTime{h.now}}
	must(t, h.run(false))
	must(t, h.run(false, "traefik-pbj"))
	h.now = h.now.Add(48 * time.Hour)
	must(t, h.run(false))
	if _, ok := h.cf.tokens[other.ID]; !ok {
		t.Fatal("token with a different name was revoked")
	}
	if _, ok := h.cf.tokens["rotator"]; !ok {
		t.Fatal("rotator token was revoked")
	}
}

func TestDryRunChangesNothing(t *testing.T) {
	h := newHarness(t)
	h.bootstrap()
	h.now = h.now.Add(60 * 24 * time.Hour)
	before := len(h.cf.tokens)
	must(t, h.run(true))
	if len(h.cf.tokens) != before || len(h.cf.deleted) != 0 || len(h.calls) != 0 {
		t.Fatal("dry run made changes")
	}
	if _, ok := h.store[h.cfg.State.String()]; ok {
		t.Fatal("dry run wrote state")
	}
	if h.store[h.primary.String()] != "initial" {
		t.Fatal("dry run wrote a target")
	}
}

func TestNewTokenThatNeverVerifiesIsDeleted(t *testing.T) {
	h := newHarness(t)
	h.bootstrap()
	must(t, h.run(false))
	// The current token verifies; any newly issued one never does.
	cf := &verifyOnly{fakeCF: h.cf, allow: "initial"}
	r := &Rotator{
		Cfg: h.cfg, CF: cf, Secrets: h.store, Notify: h.notes, Now: func() time.Time { return h.now },
		Force: map[string]bool{"all": true}, VerifyTimeout: 30 * time.Millisecond,
		Reloaders: func(context.Context, ReloadSpec) (Reloader, error) { return nil, errors.New("unused") },
	}
	if err := r.Run(context.Background()); err == nil {
		t.Fatal("expected error")
	}
	if len(h.cf.deleted) != 1 {
		t.Fatalf("expected the unverifiable new token to be deleted, deleted=%v", h.cf.deleted)
	}
	if h.store[h.primary.String()] != "initial" {
		t.Fatal("primary overwritten with unverified token")
	}
}

type verifyOnly struct {
	*fakeCF
	allow string
}

func (v *verifyOnly) Verify(ctx context.Context, val string) (string, error) {
	if val != v.allow {
		return "", errors.New("not yet")
	}
	return v.fakeCF.Verify(ctx, val)
}

func TestMisnamedTokenIsRejected(t *testing.T) {
	h := newHarness(t)
	h.cf.add("some other name", "initial", h.now)
	h.store[h.primary.String()] = "initial"
	err := h.run(false)
	if err == nil || !strings.Contains(err.Error(), "rename it") {
		t.Fatalf("expected rename error, got %v", err)
	}
}

func TestReplacePluginVar(t *testing.T) {
	got := replacePluginVar("CF_Account_ID=abc\nCF_Token=old\n", "CF_Token", "new")
	if got != "CF_Account_ID=abc\nCF_Token=new" {
		t.Fatalf("got %q", got)
	}
	if got := replacePluginVar("", "CF_Token", "new"); got != "CF_Token=new" {
		t.Fatalf("got %q", got)
	}
}

func TestExampleConfigValidates(t *testing.T) {
	if _, err := LoadConfig("../../kubernetes/apps/base/cf-token-rotator/config.yaml"); err != nil {
		t.Fatal(err)
	}
}

func must(t *testing.T, err error) {
	t.Helper()
	if err != nil {
		t.Fatal(err)
	}
}
