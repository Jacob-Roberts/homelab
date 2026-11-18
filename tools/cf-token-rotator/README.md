# cf-token-rotator

Rotates the Cloudflare API tokens used by cert-manager, external-dns, Traefik
on every Docker host, and the Proxmox ACME plugin. It uses no paid Infisical
features.

Runs daily as a suspended-by-default CronJob
(`kubernetes/apps/base/cf-token-rotator`). Config:
`kubernetes/apps/base/cf-token-rotator/config.yaml`.

## What a run does, per consumer

1. Reads the current token from the consumer's first Infisical target and
   identifies it with Cloudflare's `verify` endpoint.
2. **Rotates** if the token is older than `rotation.interval` (30d) or expires
   within it. The new token is a clone of the current one (same policies,
   same IP condition), named `<tokenName> @ <timestamp>`, with
   `expires_on = now + rotation.expiry` (60d). The rotator verifies it before
   writing it to Infisical. If verification or the write fails, it deletes
   the new token again.
3. **Syncs** every other target to the same value.
4. **Reloads** the consumer if it hasn't run on this token yet:
   - `k8s-secret`: waits until the Infisical operator has synced the value
     into the Kubernetes Secret.
   - `k8s-rollout`: `rollout restart`, then waits for the rollout.
   - `doco-cd`: `POST /v1/api/project/traefik/recreate`. A recreate fetches
     `external_secrets` from Infisical again, so Traefik restarts with the
     new token.
   - `proxmox`: rewrites `CF_Token` in the ACME plugin data and keeps the
     other keys.

   On success it records `{reloadedTokenId, reloadedAt}` in the `STATE`
   secret. On failure the state is left unchanged, so the reload is retried
   on the next run, and nothing is revoked in the meantime.
5. **Revokes** older tokens with the same `tokenName` once `rotation.grace`
   (24h) has passed since the successful reload. If an old token's
   `last_used_on` is later than `reloadedAt + settle`, something still holds
   it: the rotator skips it and alerts instead.

It sends one ntfy message per run: high priority if anything failed or was
skipped, normal priority listing what was rotated or revoked, and nothing if
nothing happened. It also warns 30 days before its own rotator token
expires.

### Safety rails

- It only deletes tokens whose name is exactly `tokenName` or starts with
  `tokenName @ `, and never the current token or its own.
- A consumer whose current token has any other name is refused, with an
  error telling you to rename it.
- `-dry-run` changes nothing. That covers Cloudflare, Infisical, reloads and
  state.
- Infisical keeps a version history for each secret. If a new token turns
  out bad, restore the previous version: the old token is still valid
  during the grace period.
- New tokens expire after 60 days, so if the rotator stops running, things
  break where you can see it.

## One-time setup

Do steps 1 to 6 **before merging** the PR that enables this. In particular,
doco-cd's self-update fails on hosts that don't have `/opt/doco-cd/api_secret`
yet.

All secrets are in the Infisical project `f3732b81-…`, environment `prod`.

### 1. Cloudflare rotator token

Create an **account-owned** token (Manage Account → Account API Tokens):

- Permission: *Account → Account API Tokens → Edit*. Nothing else.
- Client IP filter: the cluster's egress IP.
- TTL: optional, e.g. one year. You rotate this one by hand.

Store it as `/global/cf-token-rotator/CLOUDFLARE_ROTATOR_TOKEN`, and the
account ID as `/global/cf-token-rotator/CLOUDFLARE_ACCOUNT_ID`.

### 2. One token per consumer

Create **account-owned** tokens named **exactly** as listed. Give each only
*Zone → DNS → Edit* and *Zone → Zone → Read* on the zones it needs. Where a
host has a stable egress IP, add a client IP filter, and **include the
cluster's egress IP in it**. The rotator calls `verify` with each token from
the cluster, and Cloudflare applies the filter to that call too. The
rotator copies policies and filters onto every new token, so set them up
correctly now.

| tokenName                | Store value at                                 |
|--------------------------|------------------------------------------------|
| `homelab/cert-manager`   | `/pbj/k8s/CLOUDFLARE_API_TOKEN_CERT_MANAGER`   |
| `homelab/external-dns`   | `/pbj/k8s/CLOUDFLARE_API_TOKEN_EXTERNAL_DNS`   |
| `homelab/traefik-pbj`    | `/pbj/traefik/CF_DNS_API_TOKEN`                |
| `homelab/traefik-pbj-pi` | `/pbj-pi-1/traefik/CF_DNS_API_TOKEN`           |
| `homelab/traefik-slc1`   | `/slc1-node-3/traefik/CF_DNS_API_TOKEN`        |
| `homelab/traefik-iad1`   | `/iad1-node-1/traefik/CF_DNS_API_TOKEN`        |
| `homelab/traefik-sgu1`   | `/sgu1-node-1/traefik/CF_DNS_API_TOKEN` (consumer disabled for now, see below) |
| `homelab/proxmox`        | `/pbj/proxmox/CF_DNS_API_TOKEN`                |

### 3. Infisical machine identity for the rotator

Create a separate universal-auth identity named `cf-token-rotator`. Don't
reuse the operator's identity.

- **Read and write**: every path in the table above, plus
  `/global/cf-token-rotator/STATE`. Create `STATE` empty or leave it out;
  the rotator creates it.
- **Read**: `/global/cf-token-rotator/*`, `/<host>/doco-cd/API_SECRET`,
  `/pbj/proxmox/CF_ROTATOR_PVE_API_TOKEN`.

Store its credentials as `INFISICAL_CLIENT_ID` and `INFISICAL_CLIENT_SECRET`
under `/global/cf-token-rotator/identity`. The cluster's existing operator
identity (`infisical-auth`) needs **read** on that folder to sync it into
the CronJob's Secret.

### 4. ntfy

Store the topic URL (e.g. `https://ntfy.sh/<long-random-topic>` or your own
server) as `/global/cf-token-rotator/NTFY_URL`. For a protected topic, also
store `NTFY_TOKEN` and uncomment `ntfy.token` in the config.

### 5. doco-cd API on each Docker host

On pbj, pbj-pi, slc1 and iad1:

```sh
openssl rand -hex 32 | sudo tee /opt/doco-cd/api_secret >/dev/null
sudo chmod 600 /opt/doco-cd/api_secret
```

Store the same value at `/<host-path>/doco-cd/API_SECRET` (`/pbj`,
`/pbj-pi-1`, `/slc1-node-3`, `/iad1-node-1`). The API listens on
`<netbird-ip>:9120` only. Add a Netbird ACL so that only the k8s nodes can
reach port 9120 on these hosts.

**sgu1** has no Netbird IP in the repo yet. To enable it: add
`NETBIRD_IP_V4` and `compose.api.yaml` to its doco-cd entry in
`docker/clusters/sgu1/.doco-cd.yml`, set the URL in the config, and remove
`disabled: true`.

### 6. Proxmox API token

```sh
pveum role add CFTokenRotator -privs Sys.Modify
pveum user add cf-rotator@pve
pveum acl modify / -user cf-rotator@pve -role CFTokenRotator
pveum user token add cf-rotator@pve rotator --privsep 0
```

Store `cf-rotator@pve!rotator=<uuid>` as
`/pbj/proxmox/CF_ROTATOR_PVE_API_TOKEN`. The ACME plugin ID must match
`plugin:` in the config (default `cloudflare`), and its data must use
`CF_Token` (an API token), not `CF_Key`/`CF_Email`.

## Rollout

1. Finish setup steps 1 to 6.
2. Merge the PR. Then tag a release so CI builds the image:
   `git tag cf-token-rotator/v0.1.0 && git push origin cf-token-rotator/v0.1.0`.
   New GHCR packages start out private: make
   `ghcr.io/jacob-roberts/cf-token-rotator` public, or add an
   imagePullSecret.
3. Dry run (works while the CronJob is suspended):
   ```sh
   kubectl -n cf-token-rotator create job rot-dry --from=cronjob/cf-token-rotator \
     --dry-run=client -o json \
     | jq '.spec.template.spec.containers[0].args += ["-dry-run"]' \
     | kubectl apply -f -
   kubectl -n cf-token-rotator logs -f job/rot-dry
   ```
4. First real run, with `-force all`. Every consumer then gets a
   rotator-issued token and is reloaded, so nothing is left on the old
   shared token. Run it the same way, replacing `-dry-run` with `-force` and
   `all`.
5. Once everything renews cleanly, revoke the **old shared token(s)** by
   hand. They aren't named `homelab/...`, so the rotator never touches them.
6. Unsuspend the CronJob (`suspend: false` in `cronjob.yaml`) in a PR.

## Flags

| Flag | Meaning |
|---|---|
| `-config` | config path (default `/etc/cf-token-rotator/config.yaml`) |
| `-dry-run` | log only |
| `-force a,b` / `-force all` | rotate now, whatever the token's age |
| `-only a,b` | process only these consumers |
| `-validate` | check the config file and exit |

Environment: `INFISICAL_CLIENT_ID` and `INFISICAL_CLIENT_SECRET`, or their
`_FILE` variants.

## Development

```sh
cd tools/cf-token-rotator
go test -race ./...   # also validates the real config.yaml
```
