# Kind Setup

```
kind create cluster --config kind-config.yaml
```

Now apply the gateway CRDS

```
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml
```

Now install Cilium

```
helm install cilium oci://quay.io/cilium/charts/cilium --version 1.20.0 --namespace kube-system --set k8sServiceHost=kind-control-plane --set k8sServicePort=6443 --set kubeProxyReplacement=true --set gatewayAPI.enabled=true --set l7Proxy=true
```

Wait for everything to be ready

```
k wait --for=condition=Ready nodes --all --timeout=2m
```

Now flux bootstrap

```
flux bootstrap github --owner=Jacob-Roberts --repository=homelab --branch=main --path=kubernetes/clusters/local --personal
```

And now to access the node, port forward into the cluster

```
k port-forward deploy/gw-proxy 8080:8080
```
