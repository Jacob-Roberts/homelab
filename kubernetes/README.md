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
| `*.jakerob.pro`          | `https-jakerob` | `jakerob-wildcard-cert`  |
| `*.pbj.jakerob.pro`      | `https-pbj`     | `pbj-wildcard-cert`      |
| `*.pbj-kube.jakerob.pro` | `https-pbj-kube`| `pbj-kube-wildcard-cert` |

`*.pbj-kube.jakerob.pro` is transitional. As services move to
`*.pbj.jakerob.pro`, shrink the listener and delete its certificate once the
last hostname has moved.

## Publishing a service to the internet

By default a service is LAN-only: its HTTPRoute attaches to `my-gateway`, so
external-dns publishes an A record to `192.168.42.200` and only machines that
can reach the cluster network resolve it.

To publish a service while keeping your local split-horizon intact, keep the
route on `my-gateway` and forward from iad1 to it. Opt in by **excluding** the
route from external-dns so Terraform can own the public record:

1. Add `external-dns.kubernetes.io/controller: manual` to the HTTPRoute so
   external-dns stops managing its DNS record (per-route opt-out; the default
   `dns-controller` is managed).
2. Add a CNAME in `terraform/cloudflare/jakerob.pro/records.tf` pointing the
   hostname to `iad1-node-1.jakerob.pro`.
3. Add an http redirect + https router in
   `docker-compose/traefik/iad1-node-1/config-external/conf/tunnel.yaml` using
   the `k8s-gateway` service (`http://192.168.42.200`) and the `letsencrypt`
   (HTTP-01) resolver. iad1 terminates TLS publicly and forwards to the
   existing gateway over Netbird with the original `Host` header.

With this pattern, home traffic uses your local split-horizon (resolving to
`192.168.42.200` directly) and never goes through the internet, while away
traffic resolves to `iad1` and proxies to `my-gateway`. No second gateway or
extra LB IP is needed.

Two things to know:

- **Netbird route prerequisite.** The direct hop assumes iad1's Netbird peer
  is in a group that receives the `PBJ 192.168.42.0/24` network route (it is
  dashboard-managed, not in this repo). Without it iad1 cannot reach
  `192.168.42.200`.
- **Transitioning a hostname external-dns already owns.** If the hostname had an
  external-dns A record, adding the `controller: manual` annotation stops
  future updates but upsert-only won't delete the existing A. Delete that `A`
  record (and its `a-<host>` TXT ownership record) in Cloudflare, apply the
  Terraform CNAME, and ensure your local DNS split-horizon still resolves the
  hostname to `192.168.42.200` so home traffic stays local.

## Storage

PersistentVolumes are backed by TrueNAS through the official `truenas-csi`
driver, installed by the `infra-controllers` Kustomization. It talks to the
TrueNAS websocket API and creates one ZFS dataset per PVC, so every volume can
be snapshotted, cloned and resized on its own.

Two NFS StorageClasses on `truenas.pbj.jakerob.pro`, both serving
`ReadWriteOnce` and `ReadWriteMany` and provisioning a dataset per PVC under
`<pool>/encrypted/k8s/pvc-<pvc-uid>` (named after the resulting PV):

- `nfs` (default, for a PVC that names no class) on the spinning `bulk-slow` pool.
- `nfs-nvme` on the NVMe `default-pool`, opted into by name.

`snapshot-controller` installs the VolumeSnapshot CRDs and the `truenas`
VolumeSnapshotClass takes ZFS snapshots.

Prerequisites, all outside the cluster:

1. TrueNAS SCALE 25.10.0+ with an API key created.
2. The pools `bulk-slow` and `default-pool`, with the datasets
   `bulk-slow/encrypted/k8s` and `default-pool/encrypted-v2/k8s`.
3. `TRUENAS_API_KEY` in Infisical at `/pbj/k8s`; the operator syncs it into the
   `truenas-api-credentials` Secret the driver reads.
4. Talos only: the node DaemonSet's `/etc/iscsi` hostPath is relaxed to
   `DirectoryOrCreate` by a postRenderer on the HelmRelease, because Talos's
   kubelet cannot see the host's `/etc/iscsi`. The planned iSCSI class (phase 2)
   additionally needs the `siderolabs/iscsi-tools` system extension on every node.
5. Talos only: both classes set `nfs.mountOptions: nolock,vers=3`. Talos ships no
   `rpc.statd`, and the driver exports each PVC as a nested dataset that NFSv4
   cannot traverse, so NFSv3 with local locking is the only combination that
   mounts.

- Create a PVC with no `storageClassName` and it uses `nfs`; set
  `storageClassName: nfs-nvme` to use the NVMe pool.
- Both classes use `reclaimPolicy: Retain`, so deleting a PVC keeps the dataset
  and its NFS export. Delete the dataset named after the PV
  (`<pool>/encrypted/k8s/pvc-<pvc-uid>`) on the appliance to reclaim space; its
  export goes with it.

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
