#!/usr/bin/env bash
# Spin up a local kind cluster for testing Kubernetes manifests without
# touching production. Requires: docker, kind, kubectl, flux (optional).
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-homelab-local}"
CONFIG="$(cd "$(dirname "$0")" && pwd)/kind-config.yaml"

if ! command -v kind >/dev/null 2>&1; then
  echo "kind is not installed. Install: https://kind.sigs.k8s.io/" >&2
  exit 1
fi
if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is not installed." >&2
  exit 1
fi

if kind get clusters | grep -qx "$CLUSTER_NAME"; then
  echo "Cluster $CLUSTER_NAME already exists."
else
  echo "Creating kind cluster $CLUSTER_NAME..."
  kind create cluster --name "$CLUSTER_NAME" --config "$CONFIG"
fi

echo "Cluster ready. Context: kind-$CLUSTER_NAME"
kubectl config use-context "kind-$CLUSTER_NAME"

# Optional: install Flux and reconcile the stage overlay for a smoke test.
if command -v flux >/dev/null 2>&1; then
  echo "Flux detected. To reconcile stage manifests run:"
  echo "  flux install"
  echo "  flux create source git flux-system --url=file:///repo --branch=stage --ignore-paths='kubernetes/clusters/**/flux-system/'"
  echo "  flux create kustomization flux-system --source=flux-system --path=./kubernetes/clusters/stage"
fi
