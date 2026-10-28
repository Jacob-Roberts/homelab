#!/usr/bin/env bash
# Tear down the local Talos cluster created by talos-up.sh.
set -euo pipefail
CLUSTER_NAME="${CLUSTER_NAME:-homelab-local}"
talosctl cluster destroy --name "$CLUSTER_NAME"
