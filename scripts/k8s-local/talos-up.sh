#!/usr/bin/env bash
# Spin up a local Talos cluster in Docker for testing Kubernetes manifests
# without touching production. Mirrors the CI e2e workflow.
# Requires: docker, talosctl, kubectl, helm, flux.
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-homelab-local}"
WORKERS="${WORKERS:-1}"
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TALOS_PATCH="$REPO_ROOT/kubernetes/clusters/stage/talos-patch.yaml"

for bin in docker talosctl kubectl helm flux; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "ERROR: $bin is not installed." >&2
    exit 1
  fi
done

if talosctl cluster show --name "$CLUSTER_NAME" >/dev/null 2>&1; then
  echo "Cluster $CLUSTER_NAME already exists."
else
  echo "Creating Talos cluster $CLUSTER_NAME ($WORKERS worker(s))..."
  talosctl cluster create docker \
    --name "$CLUSTER_NAME" \
    --workers "$WORKERS" \
    --config-patch "$TALOS_PATCH"
fi

export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"
talosctl kubeconfig --force 2>/dev/null || true
kubectl config use-context "admin@$CLUSTER_NAME" 2>/dev/null || true

echo "Waiting for nodes to be Ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

echo "Applying Gateway API CRDs..."
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml

echo "Installing Cilium..."
helm install cilium oci://quay.io/cilium/charts/cilium \
  --version 1.20.0 \
  --namespace kube-system \
  --set ipam.mode=kubernetes \
  --set k8sServiceHost=localhost \
  --set k8sServicePort=7445 \
  --set kubeProxyReplacement=true \
  --set gatewayAPI.enabled=true \
  --set l7Proxy=true \
  --set l2announcements.enabled=true \
  --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
  --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
  --set cgroup.autoMount.enabled=false \
  --set cgroup.hostRoot=/sys/fs/cgroup

echo "Installing Flux..."
flux install --components-extra source-watcher

echo "Reconciling local repo (stage overlay)..."
CURRENT_BRANCH="$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD)"
flux create source git flux-system \
  --url="file://$REPO_ROOT" \
  --branch="$CURRENT_BRANCH" \
  --ignore-paths="kubernetes/clusters/**/flux-system/" 2>/dev/null || true
flux create kustomization flux-system \
  --source=flux-system \
  --path=./kubernetes/clusters/stage 2>/dev/null || true

echo ""
echo "Cluster ready. Context: admin@$CLUSTER_NAME"
echo "Verify with: flux get all --all-namespaces"
