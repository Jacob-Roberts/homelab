# Let each TLS edge mint its own certificates

Date: 2026-10-23

Status: accepted

## Context

Several hostnames are served by more than one Traefik instance depending on
where the client resolves them:

| Client | Resolves to | TLS terminates at |
|--------|-------------|-------------------|
| Public internet | `iad1-node-1` (150.136.144.201) | IAD1 external Traefik |
| Local network | SLC1 (192.168.97.133) | SLC1 Traefik |

`auth.autovation.com` is the clearest example: public DNS points at IAD1, while
local split-horizon DNS points at SLC1.

Previously, only the internal edge requested certificates (DNS-01 via
Cloudflare), dumped them with `traefik-certs-dumper`, and copied them to IAD1
with Syncthing. IAD1 then loaded them as static certificates. That worked, but
it made certificate delivery a separate distributed system: a new or renewed
certificate depended on the dumper, the Syncthing peer, and file permissions on
the cloud host.

The assumption was that both edges had to present the *same* certificate. They
do not. TLS only requires that the certificate a client receives is valid for
the name it requested from the edge it connected to. The private keys never need
to be shared.

## Decision

Every TLS termination point obtains and renews its own certificate through ACME:

- **Public edges** (IAD1 external Traefik) use HTTP-01. Every hostname routed by
  that instance has public DNS pointing at IAD1, so the challenge reaches the
  instance directly. No Cloudflare API token is needed there.
- **Internal edges** (SLC1, PBJ, LHR1) keep using DNS-01 via Cloudflare, which
  does not require the name to resolve to that host.

Certificates are stored locally per instance (`/traefik/certs/acme.json`).
Static certificates and the Syncthing certificate sync to IAD1 are removed.

## Consequences

- A certificate renewal on one edge no longer depends on another host being
  online, nor on file permissions or Syncthing folder state.
- The two edges will have different certificates (different serial numbers and
  validity windows) for the same hostname. This is expected and valid.
- Backend hops remain encrypted with `insecureSkipVerify` because the tunnel
  certificates are managed independently of the public edge certificate. The
  client-facing certificate is the one that matters for trust.
- If a hostname no longer resolves to IAD1 publicly, its certificate cannot be
  renewed with HTTP-01. At that point either switch that router to a DNS-01
  resolver or stop routing it through IAD1.
- Certificates that are no longer needed can be removed from `acme.json`; no
  other host depends on a copy.
