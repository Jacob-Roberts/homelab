package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"
)

// CFTime tolerates null and "" as well as RFC 3339 timestamps.
type CFTime struct{ time.Time }

func (t *CFTime) UnmarshalJSON(b []byte) error {
	s := strings.Trim(string(b), `"`)
	if s == "" || s == "null" {
		t.Time = time.Time{}
		return nil
	}
	v, err := time.Parse(time.RFC3339Nano, s)
	if err != nil {
		return err
	}
	t.Time = v
	return nil
}

type CFPermissionGroup struct {
	ID   string          `json:"id"`
	Name string          `json:"name,omitempty"`
	Meta json.RawMessage `json:"meta,omitempty"`
}

type CFPolicy struct {
	ID               string              `json:"id,omitempty"`
	Effect           string              `json:"effect"`
	Resources        json.RawMessage     `json:"resources"`
	PermissionGroups []CFPermissionGroup `json:"permission_groups"`
}

type CFToken struct {
	ID         string          `json:"id"`
	Name       string          `json:"name"`
	Status     string          `json:"status"`
	IssuedOn   CFTime          `json:"issued_on"`
	LastUsedOn CFTime          `json:"last_used_on"`
	ExpiresOn  CFTime          `json:"expires_on"`
	Policies   []CFPolicy      `json:"policies"`
	Condition  json.RawMessage `json:"condition,omitempty"`
	Value      string          `json:"value,omitempty"` // only set on create
}

// Cloudflare is the subset of the account API-token API the rotator uses.
type Cloudflare interface {
	// Verify returns the ID of the token whose value is given.
	Verify(ctx context.Context, value string) (string, error)
	GetToken(ctx context.Context, id string) (*CFToken, error)
	ListTokens(ctx context.Context) ([]CFToken, error)
	// CreateClone creates a token with src's policies and condition.
	CreateClone(ctx context.Context, src *CFToken, name string, expiresOn time.Time) (*CFToken, error)
	DeleteToken(ctx context.Context, id string) error
}

type cloudflareClient struct {
	http      *http.Client
	baseURL   string
	accountID string
	token     string // rotator token
}

func NewCloudflare(accountID, rotatorToken string) *cloudflareClient {
	return &cloudflareClient{
		http:      &http.Client{Timeout: 30 * time.Second},
		baseURL:   "https://api.cloudflare.com/client/v4",
		accountID: accountID,
		token:     rotatorToken,
	}
}

type cfEnvelope struct {
	Success bool `json:"success"`
	Errors  []struct {
		Code    int    `json:"code"`
		Message string `json:"message"`
	} `json:"errors"`
	Result     json.RawMessage `json:"result"`
	ResultInfo *struct {
		Page       int `json:"page"`
		TotalPages int `json:"total_pages"`
	} `json:"result_info"`
}

func (c *cloudflareClient) do(ctx context.Context, method, path, bearer string, body any, out any) (*cfEnvelope, error) {
	var rd io.Reader
	if body != nil {
		b, err := json.Marshal(body)
		if err != nil {
			return nil, err
		}
		rd = bytes.NewReader(b)
	}
	req, err := http.NewRequestWithContext(ctx, method, c.baseURL+path, rd)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Authorization", "Bearer "+bearer)
	req.Header.Set("Content-Type", "application/json")
	resp, err := c.http.Do(req)
	if err != nil {
		return nil, fmt.Errorf("cloudflare %s %s: %w", method, path, err)
	}
	defer resp.Body.Close()
	raw, _ := io.ReadAll(io.LimitReader(resp.Body, 4<<20))
	var env cfEnvelope
	if err := json.Unmarshal(raw, &env); err != nil {
		return nil, fmt.Errorf("cloudflare %s %s: HTTP %d, unparseable body", method, path, resp.StatusCode)
	}
	if !env.Success || resp.StatusCode >= 300 {
		var msgs []string
		for _, e := range env.Errors {
			msgs = append(msgs, fmt.Sprintf("%d %s", e.Code, e.Message))
		}
		return nil, fmt.Errorf("cloudflare %s %s: HTTP %d: %s", method, path, resp.StatusCode, strings.Join(msgs, "; "))
	}
	if out != nil {
		if err := json.Unmarshal(env.Result, out); err != nil {
			return nil, fmt.Errorf("cloudflare %s %s: decode result: %w", method, path, err)
		}
	}
	return &env, nil
}

func (c *cloudflareClient) tokensPath() string {
	return "/accounts/" + url.PathEscape(c.accountID) + "/tokens"
}

func (c *cloudflareClient) Verify(ctx context.Context, value string) (string, error) {
	var res struct {
		ID     string `json:"id"`
		Status string `json:"status"`
	}
	if _, err := c.do(ctx, http.MethodGet, c.tokensPath()+"/verify", value, nil, &res); err != nil {
		return "", err
	}
	if res.Status != "active" {
		return res.ID, fmt.Errorf("token %s status is %q", res.ID, res.Status)
	}
	return res.ID, nil
}

func (c *cloudflareClient) GetToken(ctx context.Context, id string) (*CFToken, error) {
	var t CFToken
	if _, err := c.do(ctx, http.MethodGet, c.tokensPath()+"/"+url.PathEscape(id), c.token, nil, &t); err != nil {
		return nil, err
	}
	return &t, nil
}

func (c *cloudflareClient) ListTokens(ctx context.Context) ([]CFToken, error) {
	var all []CFToken
	for page := 1; page < 1000; page++ {
		var batch []CFToken
		env, err := c.do(ctx, http.MethodGet, fmt.Sprintf("%s?per_page=50&page=%d", c.tokensPath(), page), c.token, nil, &batch)
		if err != nil {
			return nil, err
		}
		all = append(all, batch...)
		if env.ResultInfo == nil || page >= env.ResultInfo.TotalPages || len(batch) == 0 {
			break
		}
	}
	return all, nil
}

func (c *cloudflareClient) CreateClone(ctx context.Context, src *CFToken, name string, expiresOn time.Time) (*CFToken, error) {
	type pg struct {
		ID   string          `json:"id"`
		Meta json.RawMessage `json:"meta,omitempty"`
	}
	type policy struct {
		Effect           string          `json:"effect"`
		Resources        json.RawMessage `json:"resources"`
		PermissionGroups []pg            `json:"permission_groups"`
	}
	body := struct {
		Name      string          `json:"name"`
		Policies  []policy        `json:"policies"`
		Condition json.RawMessage `json:"condition,omitempty"`
		ExpiresOn string          `json:"expires_on,omitempty"`
	}{Name: name}
	for _, p := range src.Policies {
		np := policy{Effect: p.Effect, Resources: p.Resources}
		for _, g := range p.PermissionGroups {
			np.PermissionGroups = append(np.PermissionGroups, pg{ID: g.ID, Meta: g.Meta})
		}
		body.Policies = append(body.Policies, np)
	}
	if len(body.Policies) == 0 {
		return nil, fmt.Errorf("token %s has no policies to clone", src.ID)
	}
	if c := strings.TrimSpace(string(src.Condition)); c != "" && c != "null" && c != "{}" {
		body.Condition = src.Condition
	}
	if !expiresOn.IsZero() {
		body.ExpiresOn = expiresOn.UTC().Format(time.RFC3339)
	}
	var t CFToken
	if _, err := c.do(ctx, http.MethodPost, c.tokensPath(), c.token, body, &t); err != nil {
		return nil, err
	}
	if t.Value == "" || t.ID == "" {
		return nil, fmt.Errorf("create token %q: response had no id/value", name)
	}
	return &t, nil
}

func (c *cloudflareClient) DeleteToken(ctx context.Context, id string) error {
	_, err := c.do(ctx, http.MethodDelete, c.tokensPath()+"/"+url.PathEscape(id), c.token, nil, nil)
	return err
}
