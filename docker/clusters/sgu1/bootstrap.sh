#!/usr/bin/env sh
# One-shot bootstrap: creates the doco-cd stack from the repo and exits.
# After this, doco-cd manages its own stack like any other application.
# Run this script once per host and never again.
set -eu

# Use the same release version as infra-repo/doco-cd/compose.yaml.
# https://github.com/kimdre/doco-cd/releases
IMAGE="ghcr.io/kimdre/doco-cd:0.133.2"
DATA_VOLUME="doco-cd_data"
REPO_URL="https://github.com/Jacob-Roberts/homelab.git"
# Hosts that may receive GIT_ACCESS_TOKEN. Use the host of REPO_URL.
GIT_AUTH_DOMAINS="${GIT_AUTH_DOMAINS:-"- domains: [github.com]"}"

docker volume create "$DATA_VOLUME" >/dev/null

# The Docker API proxy is its own Compose project, outside doco-cd's stack, so
# doco-cd's self-update can never recreate it mid-deploy. Start it first and
# update it by hand (re-running this block is safe).
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PROXY_COMPOSE="$SCRIPT_DIR/../../infrastructure/docker-socket-proxy/compose.yaml"
docker network inspect docker-socket-proxy >/dev/null 2>&1 \
  || docker network create --internal docker-socket-proxy >/dev/null
docker compose -f "$PROXY_COMPOSE" up -d --wait

# Add other app settings via environment variables as needed,
# e.g. GIT_ACCESS_TOKEN or SOPS_AGE_KEY
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "/opt/doco-cd/infisical_client_secret:/run/secrets/infisical_client_secret:ro" \
  -v "$DATA_VOLUME":/data \
  -e SELF_UPDATE_ENABLED=true \
  -e GIT_ACCESS_TOKEN="${GIT_ACCESS_TOKEN:-}" \
  -e GIT_AUTH_DOMAINS="$GIT_AUTH_DOMAINS" \
  -e GIT_AUTH_ALLOW_ANY_HOST="${GIT_AUTH_ALLOW_ANY_HOST:-false}" \
  -e DEPLOY_CONFIG_BASE_DIR="docker/clusters/sgu1" \
  -e SECRET_PROVIDER="infisical" \
  -e SECRET_PROVIDER_SITE_URL="https://app.infisical.com" \
  -e SECRET_PROVIDER_CLIENT_ID="bee04ce7-0037-4531-9e59-a2d015f7f2a2" \
  -e SECRET_PROVIDER_CLIENT_SECRET_FILE="/run/secrets/infisical_client_secret" \
  -e POLL_CONFIG="- url: $REPO_URL
  reference: main" \
  "$IMAGE" apply-self --bootstrap
