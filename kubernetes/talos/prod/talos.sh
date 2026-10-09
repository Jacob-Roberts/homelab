#!/usr/bin/env bash
#
# Talos management for the prod cluster.
#
# The cluster secrets bundle lives in Infisical, never in git. Machine configs
# and the client talosconfig are derived from it on demand and are gitignored.
#
# Most commands must be run through infisical-run.sh so that TALOS_SECRETS is
# injected into the environment:
#
#   ./infisical-run.sh ./talos.sh gen
#   ./infisical-run.sh ./talos.sh apply-insecure   # first boot
#   ./infisical-run.sh ./talos.sh bootstrap
#   ./infisical-run.sh ./talos.sh apply            # day-2
#   ./infisical-run.sh ./talos.sh kubeconfig
#
# The one-time secret upload talks to Infisical directly:
#
#   ./talos.sh secrets-init
#
# Non-secret settings can be overridden with environment variables:
#   TALOS_CLUSTER, TALOS_ENDPOINT, CONTROLPLANE_NODES, WORKER_NODES,
#   PATCH, OUT_DIR, INFISICAL_PATH, INFISICAL_KEY, KUBECONFIG_OUT
#
set -euo pipefail

cd -- "$(dirname -- "$0")"

TALOS_CLUSTER="${TALOS_CLUSTER:-my-proxmox-cluster}"
TALOS_ENDPOINT="${TALOS_ENDPOINT:-https://192.168.42.129:6443}"
CONTROLPLANE_NODES="${CONTROLPLANE_NODES:-192.168.42.129}"
WORKER_NODES="${WORKER_NODES:-192.168.42.54}"
PATCH="${PATCH:-talos-patch.yaml}"
OUT_DIR="${OUT_DIR:-_out}"
INFISICAL_PATH="${INFISICAL_PATH:-/pbj/k8s-talos/prod}"
INFISICAL_KEY="${INFISICAL_KEY:-TALOS_SECRETS}"

TALOSCONFIG="${OUT_DIR}/talosconfig"
CONTROLPLANE_CONFIG="${OUT_DIR}/controlplane.yaml"
WORKER_CONFIG="${OUT_DIR}/worker.yaml"

die() {
  echo "error: $*" >&2
  exit 1
}

require_secrets() {
  [ -n "${TALOS_SECRETS:-}" ] ||
    die "TALOS_SECRETS is not set; run this via ./infisical-run.sh"
}

require_talosconfig() {
  [ -f "$TALOSCONFIG" ] || die "missing ${TALOSCONFIG}; run 'gen' first"
}

gen() {
  require_secrets
  [ -f "$PATCH" ] || die "config patch not found: $PATCH"
  mkdir -p "$OUT_DIR"

  local tmpdir secrets_file
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' RETURN
  secrets_file="$tmpdir/secrets.yaml"

  printf '%s\n' "$TALOS_SECRETS" >"$secrets_file"

  talosctl gen config "$TALOS_CLUSTER" "$TALOS_ENDPOINT" \
    --with-secrets "$secrets_file" \
    --config-patch "@${PATCH}" \
    --output "$OUT_DIR" \
    --force

  echo "wrote ${CONTROLPLANE_CONFIG}, ${WORKER_CONFIG} and ${TALOSCONFIG}"
}

apply_config() {
  local insecure="$1"
  [ -f "$CONTROLPLANE_CONFIG" ] || die "missing ${CONTROLPLANE_CONFIG}; run 'gen' first"

  local -a flags=()
  if [ "$insecure" = "true" ]; then
    flags=(--insecure)
    echo "applying with the insecure (first boot) endpoint"
  else
    require_talosconfig
    flags=(--talosconfig "$TALOSCONFIG")
  fi

  local node
  for node in $CONTROLPLANE_NODES; do
    echo "applying controlplane config to ${node}"
    talosctl apply-config "${flags[@]}" --nodes "$node" --file "$CONTROLPLANE_CONFIG"
  done

  for node in $WORKER_NODES; do
    echo "applying worker config to ${node}"
    talosctl apply-config "${flags[@]}" --nodes "$node" --file "$WORKER_CONFIG"
  done
}

bootstrap() {
  require_talosconfig
  local first="${CONTROLPLANE_NODES%% *}"
  echo "bootstrapping etcd on ${first}"
  talosctl bootstrap --nodes "$first" --talosconfig "$TALOSCONFIG"
}

kubeconfig() {
  require_talosconfig
  local first="${CONTROLPLANE_NODES%% *}"
  talosctl kubeconfig --nodes "$first" --talosconfig "$TALOSCONFIG" \
    ${KUBECONFIG_OUT:+"$KUBECONFIG_OUT"}
}

secrets_init() {
  command -v infisical >/dev/null ||
    die "infisical CLI not found; install it (see mise.toml)"

  local tmpdir secrets_file
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' RETURN
  secrets_file="$tmpdir/secrets.yaml"

  talosctl gen secrets -o "$secrets_file"
  infisical secrets set "${INFISICAL_KEY}=$(cat "$secrets_file")" --projectId="f3732b81-3a85-430d-a547-43b85c363ad6" --path "$INFISICAL_PATH"
  echo "uploaded ${INFISICAL_KEY} to Infisical at ${INFISICAL_PATH}"
  echo "keep a copy of this bundle somewhere safe; losing it means losing the cluster"
}

case "${1:-}" in
  gen) gen ;;
  apply) apply_config false ;;
  apply-insecure) apply_config true ;;
  bootstrap) bootstrap ;;
  kubeconfig) kubeconfig ;;
  secrets-init) secrets_init ;;
  *)
    echo "usage: $0 {gen|apply|apply-insecure|bootstrap|kubeconfig|secrets-init}" >&2
    exit 1
    ;;
esac
