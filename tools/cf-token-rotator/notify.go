package main

import (
	"context"
	"fmt"
	"log/slog"
	"net/http"
	"strings"
	"time"
)

type Notifier interface {
	Notify(ctx context.Context, title, priority, tags, message string)
}

type logNotifier struct{}

func (logNotifier) Notify(_ context.Context, title, priority, _, message string) {
	slog.Info("notify", "title", title, "priority", priority, "message", message)
}

type ntfyNotifier struct {
	url, token string
}

func (n ntfyNotifier) Notify(ctx context.Context, title, priority, tags, message string) {
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, n.url, strings.NewReader(message))
	if err != nil {
		slog.Error("ntfy request", "err", err)
		return
	}
	req.Header.Set("Title", title)
	req.Header.Set("Priority", priority)
	if tags != "" {
		req.Header.Set("Tags", tags)
	}
	if n.token != "" {
		req.Header.Set("Authorization", "Bearer "+n.token)
	}
	resp, err := (&http.Client{Timeout: 15 * time.Second}).Do(req)
	if err != nil {
		slog.Error("ntfy send", "err", err)
		return
	}
	resp.Body.Close()
	if resp.StatusCode >= 300 {
		slog.Error("ntfy send", "err", fmt.Sprintf("HTTP %d", resp.StatusCode))
	}
}
