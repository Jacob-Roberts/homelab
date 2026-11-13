# Site hostnames are VPN-only; public hostnames are top-level

Date: 2026-11-13

Status: accepted

## Context

Internal and external routes were mixed together. A site hostname was not a
reliable signal of who could reach it:

- `*.iad1.jakerob.pro` pointed at iad1's public IP, so `pocket-id.iad1`,
  `plausible.iad1` and `api.spotify.iad1` were public, while iad1's
  VPN-only services used a separate `*.iad1vpn.jakerob.pro` zone.
- `whoami-tunnel.pbj`, `whoami-tunnel.slc1` and `pocket-id.pbj` had explicit
  public CNAMEs to iad1 inside otherwise VPN-only zones.
- `*.slc1.jakerob.pro` pointed at slc1's LAN IP even though its Traefik only
  listens on the Netbird IP. slc1 had no `traefik-external` at all, so its
  `traefik.external: "true"` apps (pocket-id, immich, jellyfin) were not routed
  by anything.

## Decision

One rule, everywhere (pbj, iad1, slc1):

- **`<service>.<site>.jakerob.pro` is VPN-only.** The `*.<site>` wildcard
  CNAMEs to `<node>.vpn.jakerob.pro`, and only that node's `traefik-internal`
  (bound to the Netbird IP) routes it. No public DNS record or
  `traefik-external` router may use a site hostname.
- **Anything reachable from outside the VPN gets a top-level
  `<service>.jakerob.pro` name** (or a name in another public zone, such as
  `autovation.com`), CNAMEd to `iad1-node-1.jakerob.pro`.
- Public traffic always passes through a `traefik-external` (crowdsec,
  geoblock):
  - iad1-hosted apps: iad1 `traefik-external`, `letsencrypt` (HTTP-01).
  - pbj/slc1-hosted apps: iad1 `traefik-external` -> Netbird ->
    site `traefik-internal` (`conf-internal/tunnel-<site>.yaml`) -> site
    `traefik-external` -> app, using `cloudflare` (DNS-01) on the site.
- `*.iad1vpn.jakerob.pro` is retired in favor of `*.iad1.jakerob.pro`.

Renames that follow from this:

| Old | New |
| --- | --- |
| `traefik-internal.iad1vpn.jakerob.pro` | `traefik.iad1.jakerob.pro` |
| `whoami.iad1vpn.jakerob.pro` | `whoami.iad1.jakerob.pro` |
| `whoami-external.iad1.jakerob.pro` | `whoami-iad1.jakerob.pro` |
| `whoami-tunnel.pbj.jakerob.pro` | `whoami-pbj.jakerob.pro` |
| `whoami-tunnel.slc1.jakerob.pro` | `whoami-slc1.jakerob.pro` |
| `pocket-id.iad1.jakerob.pro` | `pocket-id.jakerob.pro` |
| `plausible.iad1.jakerob.pro` | `plausible.jakerob.pro` |
| `api.spotify.iad1.jakerob.pro` | `spotify-api.jakerob.pro` |

`TRAEFIK_EXTERNAL_URL` (only used for the `/ping` router) is now the node's
own LAN/public hostname (`<node>.jakerob.pro`), the address `traefik-external`
actually binds to.

slc1 now runs `traefik-external` and crowdsec like pbj. Its jellyfin stays
VPN-only (`jellyfin.slc1.jakerob.pro`) through the new `TRAEFIK_EXTERNAL`
variable on the jellyfin compose file.

## Consequences

- The hostname alone tells you the exposure: a dot-site name is private.
- Renaming pocket-id on iad1 changes its WebAuthn relying party ID. Existing
  passkeys for `pocket-id.iad1.jakerob.pro` stop working; sign in with a
  one-time email code and register new passkeys. Mealie's OIDC discovery URL
  moves with it.
- Sites that embed the Plausible script, and the Spotify developer dashboard
  redirect URI, have to be updated to the new names.
- Infrastructure hosts that are not HTTP services behind Traefik
  (`proxmox.*`, `truenas.*`, `pbs.pbj`) keep their direct CNAMEs. They are
  LAN/VPN-only and are not exposed publicly.
- Kubernetes services under `*.pbj.jakerob.pro` are served by the LAN-only
  Cilium gateway (`192.168.42.200`), which is also VPN/LAN-only, so they
  follow the same rule even though they skip Traefik.
