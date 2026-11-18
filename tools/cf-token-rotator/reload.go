package main

import (
	"bufio"
	"bytes"
	"context"
	"crypto/tls"
	"crypto/x509"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"
)

// Reloader makes one consumer pick up a new token value.
type Reloader interface {
	Describe() string
	Reload(ctx context.Context, token string) error
}

// ReloaderFactory builds reloaders. Tests swap it for fakes.
type ReloaderFactory func(ctx context.Context, spec ReloadSpec) (Reloader, error)

func defaultReloaderFactory(secrets SecretStore) ReloaderFactory {
	var kube *kubeClient
	return func(ctx context.Context, spec ReloadSpec) (Reloader, error) {
		timeout := spec.Timeout.D()
		switch spec.Type {
		case "k8s-secret", "k8s-rollout":
			if kube == nil {
				k, err := newInClusterKube()
				if err != nil {
					return nil, err
				}
				kube = k
			}
			if timeout == 0 {
				timeout = 10 * time.Minute
			}
			if spec.Type == "k8s-secret" {
				return &k8sSecretWait{kube, spec.Namespace, spec.Secret, spec.SecretKey, timeout}, nil
			}
			return &k8sRollout{kube, spec.Namespace, spec.Deployment, timeout}, nil
		case "doco-cd":
			key, err := secrets.Get(ctx, *spec.APIKey)
			if err != nil {
				return nil, err
			}
			if timeout == 0 {
				timeout = 3 * time.Minute
			}
			return &docoCD{url: strings.TrimSuffix(spec.URL, "/"), project: spec.Project, apiKey: key, timeout: timeout}, nil
		case "proxmox":
			key, err := secrets.Get(ctx, *spec.APIKey)
			if err != nil {
				return nil, err
			}
			return &proxmoxPlugin{
				url: strings.TrimSuffix(spec.URL, "/"), plugin: spec.Plugin, tokenVar: spec.TokenVar,
				apiToken: key, insecure: spec.InsecureSkipVerify,
			}, nil
		}
		return nil, fmt.Errorf("unknown reload type %q", spec.Type)
	}
}

func readBodySnippet(r io.Reader) string {
	b, _ := io.ReadAll(io.LimitReader(r, 512))
	return strings.TrimSpace(string(b))
}

// ---------------------------------------------------------------- k8s

type kubeClient struct {
	http  *http.Client
	host  string
	token string
}

const saDir = "/var/run/secrets/kubernetes.io/serviceaccount"

func newInClusterKube() (*kubeClient, error) {
	host, port := os.Getenv("KUBERNETES_SERVICE_HOST"), os.Getenv("KUBERNETES_SERVICE_PORT")
	if host == "" || port == "" {
		return nil, errors.New("k8s reload: not running in a cluster")
	}
	token, err := os.ReadFile(saDir + "/token")
	if err != nil {
		return nil, err
	}
	ca, err := os.ReadFile(saDir + "/ca.crt")
	if err != nil {
		return nil, err
	}
	pool := x509.NewCertPool()
	if !pool.AppendCertsFromPEM(ca) {
		return nil, errors.New("k8s reload: bad service account CA")
	}
	return &kubeClient{
		http: &http.Client{Timeout: 30 * time.Second, Transport: &http.Transport{
			TLSClientConfig: &tls.Config{RootCAs: pool, MinVersion: tls.VersionTLS12},
		}},
		host:  "https://" + net.JoinHostPort(host, port),
		token: strings.TrimSpace(string(token)),
	}, nil
}

func (k *kubeClient) do(ctx context.Context, method, path, contentType string, body []byte, out any) error {
	req, err := http.NewRequestWithContext(ctx, method, k.host+path, bytes.NewReader(body))
	if err != nil {
		return err
	}
	req.Header.Set("Authorization", "Bearer "+k.token)
	if contentType != "" {
		req.Header.Set("Content-Type", contentType)
	}
	resp, err := k.http.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode >= 300 {
		return fmt.Errorf("k8s %s %s: HTTP %d: %s", method, path, resp.StatusCode, readBodySnippet(resp.Body))
	}
	if out != nil {
		return json.NewDecoder(resp.Body).Decode(out)
	}
	return nil
}

func poll(ctx context.Context, timeout, every time.Duration, check func() (bool, error)) error {
	ctx, cancel := context.WithTimeout(ctx, timeout)
	defer cancel()
	var lastErr error
	for {
		ok, err := check()
		if ok {
			return nil
		}
		lastErr = err
		select {
		case <-ctx.Done():
			if lastErr != nil {
				return fmt.Errorf("timed out after %s: %w", timeout, lastErr)
			}
			return fmt.Errorf("timed out after %s", timeout)
		case <-time.After(every):
		}
	}
}

// k8sSecretWait waits until the Infisical operator has synced the new value
// into a Kubernetes Secret. Consumers that read the Secret live (cert-manager)
// need nothing more; others follow with a k8s-rollout.
type k8sSecretWait struct {
	kube                 *kubeClient
	namespace, name, key string
	timeout              time.Duration
}

func (w *k8sSecretWait) Describe() string {
	return fmt.Sprintf("wait for Secret %s/%s[%s]", w.namespace, w.name, w.key)
}

func (w *k8sSecretWait) Reload(ctx context.Context, token string) error {
	path := fmt.Sprintf("/api/v1/namespaces/%s/secrets/%s", url.PathEscape(w.namespace), url.PathEscape(w.name))
	return poll(ctx, w.timeout, 10*time.Second, func() (bool, error) {
		var s struct {
			Data map[string]string `json:"data"`
		}
		if err := w.kube.do(ctx, http.MethodGet, path, "", nil, &s); err != nil {
			return false, err
		}
		v, err := base64.StdEncoding.DecodeString(s.Data[w.key])
		return err == nil && string(v) == token, nil
	})
}

// k8sRollout is `kubectl rollout restart` plus `rollout status`.
type k8sRollout struct {
	kube            *kubeClient
	namespace, name string
	timeout         time.Duration
}

func (r *k8sRollout) Describe() string {
	return fmt.Sprintf("rollout restart deployment %s/%s", r.namespace, r.name)
}

func (r *k8sRollout) Reload(ctx context.Context, _ string) error {
	path := fmt.Sprintf("/apis/apps/v1/namespaces/%s/deployments/%s", url.PathEscape(r.namespace), url.PathEscape(r.name))
	patch := fmt.Sprintf(`{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt":%q}}}}}`,
		time.Now().UTC().Format(time.RFC3339))
	var dep deployment
	if err := r.kube.do(ctx, http.MethodPatch, path, "application/strategic-merge-patch+json", []byte(patch), &dep); err != nil {
		return err
	}
	gen := dep.Metadata.Generation
	return poll(ctx, r.timeout, 5*time.Second, func() (bool, error) {
		var d deployment
		if err := r.kube.do(ctx, http.MethodGet, path, "", nil, &d); err != nil {
			return false, err
		}
		return d.rolledOut(gen), nil
	})
}

type deployment struct {
	Metadata struct {
		Generation int64 `json:"generation"`
	} `json:"metadata"`
	Spec struct {
		Replicas *int32 `json:"replicas"`
	} `json:"spec"`
	Status struct {
		ObservedGeneration int64 `json:"observedGeneration"`
		Replicas           int32 `json:"replicas"`
		UpdatedReplicas    int32 `json:"updatedReplicas"`
		AvailableReplicas  int32 `json:"availableReplicas"`
	} `json:"status"`
}

func (d deployment) rolledOut(gen int64) bool {
	want := int32(1)
	if d.Spec.Replicas != nil {
		want = *d.Spec.Replicas
	}
	s := d.Status
	return s.ObservedGeneration >= gen && s.UpdatedReplicas == want && s.Replicas == want && s.AvailableReplicas == want
}

// ---------------------------------------------------------------- doco-cd

// docoCD recreates a Compose project through the doco-cd REST API. A
// recreate re-resolves external_secrets from Infisical (verified against
// doco-cd v0.133.2), so the container restarts with the new token.
type docoCD struct {
	url, project, apiKey string
	timeout              time.Duration
}

func (d *docoCD) Describe() string { return fmt.Sprintf("doco-cd recreate %s at %s", d.project, d.url) }

func (d *docoCD) Reload(ctx context.Context, _ string) error {
	secs := int(d.timeout.Seconds())
	u := fmt.Sprintf("%s/v1/api/project/%s/recreate?timeout=%d", d.url, url.PathEscape(d.project), secs)
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, u, nil)
	if err != nil {
		return err
	}
	req.Header.Set("x-api-key", d.apiKey)
	resp, err := (&http.Client{Timeout: d.timeout + time.Minute}).Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode >= 300 {
		return fmt.Errorf("doco-cd recreate %s: HTTP %d: %s", d.project, resp.StatusCode, readBodySnippet(resp.Body))
	}
	return nil
}

// ---------------------------------------------------------------- proxmox

// proxmoxPlugin rewrites one key in a Proxmox ACME DNS plugin's data,
// keeping every other key. The API returns data decoded ("K=V" lines) and
// takes it base64url-encoded on update.
type proxmoxPlugin struct {
	url, plugin, tokenVar, apiToken string
	insecure                        bool
}

func (p *proxmoxPlugin) Describe() string {
	return fmt.Sprintf("proxmox ACME plugin %q (%s) at %s", p.plugin, p.tokenVar, p.url)
}

func (p *proxmoxPlugin) client() *http.Client {
	return &http.Client{Timeout: 30 * time.Second, Transport: &http.Transport{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: p.insecure, MinVersion: tls.VersionTLS12}, //nolint:gosec // opt-in for self-signed PVE
	}}
}

func (p *proxmoxPlugin) Reload(ctx context.Context, token string) error {
	endpoint := p.url + "/api2/json/cluster/acme/plugins/" + url.PathEscape(p.plugin)
	cl := p.client()

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, endpoint, nil)
	if err != nil {
		return err
	}
	req.Header.Set("Authorization", "PVEAPIToken="+p.apiToken)
	resp, err := cl.Do(req)
	if err != nil {
		return err
	}
	var got struct {
		Data struct {
			Data   string `json:"data"`
			Digest string `json:"digest"`
		} `json:"data"`
	}
	err = json.NewDecoder(resp.Body).Decode(&got)
	resp.Body.Close()
	if resp.StatusCode >= 300 {
		return fmt.Errorf("proxmox get plugin %s: HTTP %d", p.plugin, resp.StatusCode)
	}
	if err != nil {
		return fmt.Errorf("proxmox get plugin %s: %w", p.plugin, err)
	}

	data := replacePluginVar(got.Data.Data, p.tokenVar, token)
	form := url.Values{"data": {base64.RawURLEncoding.EncodeToString([]byte(data))}}
	if got.Data.Digest != "" {
		form.Set("digest", got.Data.Digest) // fail instead of clobbering a concurrent edit
	}
	req, err = http.NewRequestWithContext(ctx, http.MethodPut, endpoint, strings.NewReader(form.Encode()))
	if err != nil {
		return err
	}
	req.Header.Set("Authorization", "PVEAPIToken="+p.apiToken)
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	resp, err = cl.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode >= 300 {
		return fmt.Errorf("proxmox update plugin %s: HTTP %d: %s", p.plugin, resp.StatusCode, readBodySnippet(resp.Body))
	}
	return nil
}

// replacePluginVar sets key=value in newline-separated plugin data, keeping
// other lines and their order.
func replacePluginVar(data, key, value string) string {
	var out []string
	found := false
	sc := bufio.NewScanner(strings.NewReader(data))
	for sc.Scan() {
		line := sc.Text()
		if k, _, ok := strings.Cut(line, "="); ok && strings.TrimSpace(k) == key {
			if !found {
				out = append(out, key+"="+value)
				found = true
			}
			continue
		}
		if strings.TrimSpace(line) != "" {
			out = append(out, line)
		}
	}
	if !found {
		out = append(out, key+"="+value)
	}
	return strings.Join(out, "\n")
}
