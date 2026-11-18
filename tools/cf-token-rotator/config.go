package main

import (
	"errors"
	"fmt"
	"os"
	"strconv"
	"strings"
	"time"

	"gopkg.in/yaml.v3"
)

// SecretRef points at one secret in the configured Infisical project.
type SecretRef struct {
	Environment string `yaml:"environment"`
	Path        string `yaml:"path"`
	Key         string `yaml:"key"`
}

func (r SecretRef) String() string {
	return fmt.Sprintf("%s:%s/%s", r.Environment, strings.TrimSuffix(r.Path, "/"), r.Key)
}

func (r SecretRef) validate() error {
	if r.Environment == "" || r.Key == "" || !strings.HasPrefix(r.Path, "/") {
		return fmt.Errorf("secret ref %q needs environment, key and an absolute path", r.String())
	}
	return nil
}

// Duration accepts Go durations ("36h") plus a day suffix ("30d").
type Duration time.Duration

func (d *Duration) UnmarshalYAML(n *yaml.Node) error {
	var s string
	if err := n.Decode(&s); err != nil {
		return err
	}
	v, err := parseDuration(s)
	if err != nil {
		return err
	}
	*d = Duration(v)
	return nil
}

func parseDuration(s string) (time.Duration, error) {
	if s == "" || s == "0" {
		return 0, nil
	}
	if days, ok := strings.CutSuffix(s, "d"); ok {
		n, err := strconv.Atoi(days)
		if err != nil {
			return 0, fmt.Errorf("invalid duration %q", s)
		}
		return time.Duration(n) * 24 * time.Hour, nil
	}
	return time.ParseDuration(s)
}

func (d Duration) D() time.Duration { return time.Duration(d) }

type Config struct {
	Infisical struct {
		SiteURL   string `yaml:"siteUrl"`
		ProjectID string `yaml:"projectId"`
	} `yaml:"infisical"`

	Cloudflare struct {
		// AccountID of the account that owns the consumer tokens.
		AccountID SecretRef `yaml:"accountId"`
		// RotatorToken has "Account API Tokens: Edit" and nothing else.
		RotatorToken SecretRef `yaml:"rotatorToken"`
	} `yaml:"cloudflare"`

	Rotation struct {
		// Interval is the token age at which a new token is issued.
		Interval Duration `yaml:"interval"`
		// Grace is how long the previous token stays valid after every
		// consumer has been reloaded with the new one.
		Grace Duration `yaml:"grace"`
		// Settle: a previous token used later than (reloadedAt + settle)
		// means something still holds it, so it is not revoked.
		Settle Duration `yaml:"settle"`
		// Expiry is set as expires_on on every new token (0 = none). A dead
		// rotator then fails loudly instead of leaving tokens forever.
		Expiry Duration `yaml:"expiry"`
	} `yaml:"rotation"`

	// State holds the rotator's JSON bookkeeping (which token each consumer
	// was last reloaded with, and when).
	State SecretRef `yaml:"state"`

	Ntfy struct {
		URL   *SecretRef `yaml:"url"`
		Token *SecretRef `yaml:"token"`
	} `yaml:"ntfy"`

	Consumers []Consumer `yaml:"consumers"`
}

type Consumer struct {
	Name string `yaml:"name"`
	// TokenName is the Cloudflare token name. Rotated tokens are named
	// "<TokenName> @ <timestamp>". Only tokens with this exact name or that
	// prefix are ever revoked for this consumer.
	TokenName string `yaml:"tokenName"`
	Disabled  bool   `yaml:"disabled"`
	// Targets are every Infisical secret that holds this token. The first
	// one is the source of truth for the current value.
	Targets []SecretRef `yaml:"targets"`
	// Reload runs in order after the token changes.
	Reload []ReloadSpec `yaml:"reload"`
}

type ReloadSpec struct {
	Type string `yaml:"type"` // k8s-secret | k8s-rollout | doco-cd | proxmox

	// k8s-secret / k8s-rollout
	Namespace  string   `yaml:"namespace"`
	Secret     string   `yaml:"secret"`
	SecretKey  string   `yaml:"secretKey"`
	Deployment string   `yaml:"deployment"`
	Timeout    Duration `yaml:"timeout"`

	// doco-cd / proxmox
	URL    string     `yaml:"url"`
	APIKey *SecretRef `yaml:"apiKey"`

	// doco-cd
	Project string `yaml:"project"`

	// proxmox
	Plugin             string `yaml:"plugin"`
	TokenVar           string `yaml:"tokenVar"`
	InsecureSkipVerify bool   `yaml:"insecureSkipVerify"`
}

func LoadConfig(path string) (*Config, error) {
	raw, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var c Config
	dec := yaml.NewDecoder(strings.NewReader(string(raw)))
	dec.KnownFields(true)
	if err := dec.Decode(&c); err != nil {
		return nil, fmt.Errorf("parse %s: %w", path, err)
	}
	if c.Infisical.SiteURL == "" {
		c.Infisical.SiteURL = "https://app.infisical.com"
	}
	if c.Rotation.Settle == 0 {
		c.Rotation.Settle = Duration(time.Hour)
	}
	return &c, c.validate()
}

func (c *Config) validate() error {
	var errs []error
	add := func(format string, a ...any) { errs = append(errs, fmt.Errorf(format, a...)) }

	if c.Infisical.ProjectID == "" {
		add("infisical.projectId is required")
	}
	for name, r := range map[string]SecretRef{
		"cloudflare.accountId": c.Cloudflare.AccountID, "cloudflare.rotatorToken": c.Cloudflare.RotatorToken, "state": c.State,
	} {
		if err := r.validate(); err != nil {
			add("%s: %w", name, err)
		}
	}
	r := c.Rotation
	if r.Interval.D() < 24*time.Hour {
		add("rotation.interval must be at least 24h")
	}
	if r.Grace.D() <= 0 {
		add("rotation.grace must be > 0")
	}
	if r.Expiry.D() != 0 && r.Expiry.D() < r.Interval.D()+r.Grace.D()+48*time.Hour {
		add("rotation.expiry must be 0 or at least interval + grace + 48h, so a token never expires before its successor is live")
	}

	names, tokenNames := map[string]bool{}, map[string]bool{}
	for i, con := range c.Consumers {
		where := fmt.Sprintf("consumers[%d] (%s)", i, con.Name)
		if con.Name == "" || names[con.Name] {
			add("%s: name must be set and unique", where)
		}
		names[con.Name] = true
		if len(con.TokenName) < 8 || tokenNames[con.TokenName] {
			add("%s: tokenName must be unique and at least 8 characters", where)
		}
		tokenNames[con.TokenName] = true
		for _, other := range c.Consumers {
			if other.TokenName != con.TokenName && strings.HasPrefix(other.TokenName, con.TokenName+tokenNameSep) {
				add("%s: tokenName %q is a prefix of %q", where, con.TokenName, other.TokenName)
			}
		}
		if len(con.Targets) == 0 {
			add("%s: at least one target is required", where)
		}
		for _, t := range con.Targets {
			if err := t.validate(); err != nil {
				add("%s: %w", where, err)
			}
		}
		for j, rs := range con.Reload {
			if err := rs.validate(); err != nil {
				add("%s reload[%d]: %w", where, j, err)
			}
		}
	}
	return errors.Join(errs...)
}

func (r ReloadSpec) validate() error {
	need := func(fields map[string]string) error {
		for k, v := range fields {
			if v == "" {
				return fmt.Errorf("%s requires %s", r.Type, k)
			}
		}
		return nil
	}
	switch r.Type {
	case "k8s-secret":
		return need(map[string]string{"namespace": r.Namespace, "secret": r.Secret, "secretKey": r.SecretKey})
	case "k8s-rollout":
		return need(map[string]string{"namespace": r.Namespace, "deployment": r.Deployment})
	case "doco-cd":
		if r.APIKey == nil {
			return errors.New("doco-cd requires apiKey")
		}
		return need(map[string]string{"url": r.URL, "project": r.Project})
	case "proxmox":
		if r.APIKey == nil {
			return errors.New("proxmox requires apiKey")
		}
		return need(map[string]string{"url": r.URL, "plugin": r.Plugin, "tokenVar": r.TokenVar})
	default:
		return fmt.Errorf("unknown reload type %q", r.Type)
	}
}
