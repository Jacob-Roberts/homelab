"prod" or "production" and "stage" or "staging" are the PBJ node.

"autovation-prod" and "autovation-stage" are different.

# Adding a service

Everything runs behind one shared Gateway, `my-gateway`. The Gateway has one
HTTPS listener per DNS zone the cluster serves, and each of those listeners has
a wildcard certificate that cert-manager's gateway-shim issues and renews on its
own. So exposing a new service is just an HTTPRoute with the right hostname --
no certificate to create, no DNS record to write.

## Hostnames and DNS

`*.pbj.jakerob.pro` still resolves to `pbj-node-1` through the wildcard CNAME in
`terraform/cloudflare/jakerob.pro/records.tf`, so all the docker compose services
living on that node keep working untouched.

external-dns watches `HTTPRoute` resources that attach to this Gateway and
publishes an A record to the Gateway's load balancer IP for every hostname it
finds. That record is more specific than the wildcard, so it wins, and that
single hostname moves onto Kubernetes. The rest of the zone stays on
`pbj-node-1`.

Do not add those hostnames to Terraform as well -- Terraform and external-dns
would both own the record and fight over it.

## Zones

| Zone                     | Listener        | Certificate              |
| ------------------------ | --------------- | ------------------------ |
| `*.pbj.jakerob.pro`      | `https-pbj`     | `pbj-wildcard-cert`      |
| `*.pbj-kube.jakerob.pro` | `https-pbj-kube`| `pbj-kube-wildcard-cert` |

`*.pbj-kube.jakerob.pro` is transitional. As services move to
`*.pbj.jakerob.pro`, shrink the listener and delete its certificate once the
last hostname has moved.

## Storage

PersistentVolumes are backed by TrueNAS through the official `truenas-csi`
driver, installed by the `infra-controllers` Kustomization. It talks to the
TrueNAS websocket API and creates one ZFS dataset per PVC, so every volume can
be snapshotted, cloned and resized on its own.

Two NFS StorageClasses on `truenas.pbj.jakerob.pro`, both serving
`ReadWriteOnce` and `ReadWriteMany` and provisioning a dataset per PVC under
`<pool>/encrypted/k8s/<pvc-name>`:

- `nfs` (default, for a PVC that names no class) on the spinning `bulk-slow` pool.
- `nfs-nvme` on the NVMe `default-pool`, opted into by name.

Prerequisites, all outside the cluster:

1. TrueNAS SCALE 25.10.0+ with an API key created.
2. The pools `bulk-slow` and `default-pool`, with the datasets
   `bulk-slow/encrypted/k8s` and `default-pool/encrypted/k8s`.
3. `TRUENAS_API_KEY` in Infisical at `/pbj/k8s`; the operator syncs it into the
   `truenas-api-credentials` Secret the driver reads.
4. The `siderolabs/iscsi-tools` system extension on every Talos node. The node
   DaemonSet bind-mounts the host's `/etc/iscsi`, which the extension creates,
   and iSCSI volumes later use its `iscsiadm` at `/usr/local/sbin`.

- Create a PVC with no `storageClassName` and it uses `nfs`; set
  `storageClassName: nfs-nvme` to use the NVMe pool.
- Both classes use `reclaimPolicy: Retain`, so deleting a PVC keeps the dataset.
  Delete `<pool>/encrypted/k8s/<pvc-name>` on the appliance to reclaim space.

Smoke test:

```zsh
kubectl apply -f kubernetes/test/pvc.yaml
kubectl get pvc nfs-test -w          # should reach Bound
kubectl logs pod/nfs-test            # prints hello-from-k8s
kubectl delete -f kubernetes/test/pvc.yaml
```

Block storage for databases (iSCSI, `ReadWriteOnce`) is planned as a second
StorageClass; it needs the same `iscsi-tools` extension.

## Steps

1. Create `kubernetes/apps/base/<service>/` with a `namespace.yaml`, whatever
   runs the workload, an `http-route.yaml`, and a `kustomization.yaml` that
   lists all of them. Use `beszel` or `whoami` as the template.

2. The base hostname should be `<service>.docker.localhost` so it still works
   locally via the port-forward proxy in `kubernetes/test/`.

3. Add the app to `kubernetes/apps/<env>/kustomization.yaml` resources.

4. Add `apps/<env>/<service>-values.yaml` that patches the base hostname to the
   real one, and reference it from the overlay's `kustomization.yaml`.

Two things bite here, and neither fails the build:

- A file that is not in the overlay's `resources` is simply never built. If you
  forget `http-route.yaml` in the base `kustomization.yaml`, or forget the app in
  the overlay, the route just does not exist.
- A patch `target` that matches nothing is a silent no-op, exit code and all.
  `kubectl kustomize <overlay>` and check the hostnames actually changed.

The `apiVersion` and `kind` inside a patch file are cosmetic while a `target`
selector is present, since `target` is what picks the resource. Keep them
accurate anyway so the file still works if the `target` is ever dropped.
