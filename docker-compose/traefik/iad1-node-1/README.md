# Traefik IAD1

Because IAD1 is a cloud VPS, I can use this to mimic the cloudflare tunnel and expose my local services without ever needing to do DDNS or Port Forwarding.

I'll use netbird to connect to the different services I want.

## TLS

Every public hostname routed by `traefik-external` resolves to IAD1, so this
instance mints its own certificates with the `letsencrypt` resolver (HTTP-01).
It does not consume certificates from any other host.

Internal edges that serve the same names over split-horizon DNS (for example
`auth.autovation.com` on SLC1) mint their own certificates separately. The
private keys are intentionally not shared; see
`docs/decisions/002-split-horizon-tls.md`.
