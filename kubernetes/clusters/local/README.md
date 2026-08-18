# Kind Setup

```zsh
kind create cluster --config kind-config.yaml
```

Now apply the gateway CRDS

```zsh
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml
```

Now install Cilium

```zsh
helm install cilium oci://quay.io/cilium/charts/cilium --version 1.20.0 --namespace kube-system --set k8sServiceHost=kind-control-plane --set k8sServicePort=6443 --set kubeProxyReplacement=true --set gatewayAPI.enabled=true --set l7Proxy=true
```

Wait for everything to be ready

```zsh
k wait --for=condition=Ready nodes --all --timeout=2m
```

Now flux bootstrap

```zsh
flux bootstrap github --owner=Jacob-Roberts --repository=homelab --branch=main --path=kubernetes/clusters/local/kind --personal --components-extra=source-watcher
```

And now to access the node, port forward into the cluster

```zsh
k port-forward deploy/gw-proxy 8080:8080
```

## Finished

Delete the cluster

```zsh
kind delete cluster
```

# Talos Setup


```zsh
talosctl cluster create docker --name dev-cluster --config-patch ./talos-patch.yaml
```

Fetch the kubeconfig

```zsh
talosctl kubeconfig --force
```

Now apply the gateway CRDS

```zsh
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml
```

Now install Cilium

```zsh
helm install cilium oci://quay.io/cilium/charts/cilium \
  --version 1.20.0 \
  --namespace kube-system\
  --set k8sServiceHost=localhost \
  --set k8sServicePort=7445 \
  --set kubeProxyReplacement=true \
  --set gatewayAPI.enabled=true \
  --set l7Proxy=true \
  --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
  --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
  --set cgroup.autoMount.enabled=false \
  --set cgroup.hostRoot=/sys/fs/cgroup
```

Wait for everything to be ready

```zsh
k wait --for=condition=Ready nodes --all --timeout=2m
```

Now flux bootstrap

```zsh
flux bootstrap github --owner=Jacob-Roberts --repository=homelab --branch=main --path=kubernetes/clusters/local/talos --personal --components-extra=source-watcher
```

And now to access the node, port forward into the cluster

```zsh
k port-forward deploy/gw-proxy 8080:8080
```

## Finished

Delete the cluster

```zsh
talosctl cluster destroy
```
