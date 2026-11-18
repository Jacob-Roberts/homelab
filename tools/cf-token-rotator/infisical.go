package main

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"
)

var ErrSecretNotFound = errors.New("secret not found")

// SecretStore reads and writes single secrets.
type SecretStore interface {
	Get(ctx context.Context, ref SecretRef) (string, error)
	Set(ctx context.Context, ref SecretRef, value string) error
}

// infisicalClient talks to the Infisical v3 raw secrets API (the same
// endpoints the official Go SDK uses) with a universal-auth machine identity.
type infisicalClient struct {
	http      *http.Client
	apiURL    string
	projectID string
	token     string
}

func NewInfisical(ctx context.Context, siteURL, projectID, clientID, clientSecret string) (*infisicalClient, error) {
	c := &infisicalClient{
		http:      &http.Client{Timeout: 30 * time.Second},
		apiURL:    strings.TrimSuffix(strings.TrimSuffix(siteURL, "/"), "/api") + "/api",
		projectID: projectID,
	}
	var res struct {
		AccessToken string `json:"accessToken"`
	}
	err := c.do(ctx, http.MethodPost, "/v1/auth/universal-auth/login", map[string]string{
		"clientId": clientID, "clientSecret": clientSecret,
	}, &res)
	if err != nil {
		return nil, fmt.Errorf("infisical login: %w", err)
	}
	if res.AccessToken == "" {
		return nil, errors.New("infisical login: empty access token")
	}
	c.token = res.AccessToken
	return c, nil
}

func (c *infisicalClient) do(ctx context.Context, method, path string, body, out any) error {
	var rd io.Reader
	if body != nil {
		b, err := json.Marshal(body)
		if err != nil {
			return err
		}
		rd = bytes.NewReader(b)
	}
	req, err := http.NewRequestWithContext(ctx, method, c.apiURL+path, rd)
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/json")
	if c.token != "" {
		req.Header.Set("Authorization", "Bearer "+c.token)
	}
	resp, err := c.http.Do(req)
	if err != nil {
		return fmt.Errorf("infisical %s: %w", method, err)
	}
	defer resp.Body.Close()
	raw, _ := io.ReadAll(io.LimitReader(resp.Body, 4<<20))
	if resp.StatusCode == http.StatusNotFound {
		return ErrSecretNotFound
	}
	if resp.StatusCode >= 300 {
		var e struct {
			Message string `json:"message"`
		}
		_ = json.Unmarshal(raw, &e)
		// Never include the request body: it may carry a secret value.
		return fmt.Errorf("infisical %s %s: HTTP %d: %s", method, strings.SplitN(path, "?", 2)[0], resp.StatusCode, e.Message)
	}
	if out != nil {
		return json.Unmarshal(raw, out)
	}
	return nil
}

func secretPath(p string) string {
	if p == "" {
		return "/"
	}
	return p
}

func (c *infisicalClient) Get(ctx context.Context, ref SecretRef) (string, error) {
	q := url.Values{
		"workspaceId":            {c.projectID},
		"environment":            {ref.Environment},
		"secretPath":             {secretPath(ref.Path)},
		"type":                   {"shared"},
		"expandSecretReferences": {"true"},
		"include_imports":        {"false"},
	}
	var res struct {
		Secret struct {
			SecretValue string `json:"secretValue"`
		} `json:"secret"`
	}
	err := c.do(ctx, http.MethodGet, "/v3/secrets/raw/"+url.PathEscape(ref.Key)+"?"+q.Encode(), nil, &res)
	if err != nil {
		return "", fmt.Errorf("get %s: %w", ref, err)
	}
	return res.Secret.SecretValue, nil
}

func (c *infisicalClient) Set(ctx context.Context, ref SecretRef, value string) error {
	body := map[string]any{
		"workspaceId": c.projectID,
		"environment": ref.Environment,
		"secretPath":  secretPath(ref.Path),
		"type":        "shared",
		"secretValue": value,
	}
	p := "/v3/secrets/raw/" + url.PathEscape(ref.Key)
	err := c.do(ctx, http.MethodPatch, p, body, nil)
	if errors.Is(err, ErrSecretNotFound) {
		err = c.do(ctx, http.MethodPost, p, body, nil)
	}
	if err != nil {
		return fmt.Errorf("set %s: %w", ref, err)
	}
	return nil
}
