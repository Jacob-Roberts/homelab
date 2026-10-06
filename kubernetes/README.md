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

## Steps

1. Create `kubernetes/apps/base/<service>/` with a `namespace.yaml`, whatever
   runs the workload, an `http-route.yaml`, and a `kustomization.yaml` that
   lists all of them. Use `beszel` or `whoami` as the template.

2. The base hostname should be `<service>.docker.localhost` so it still works
   locally via the port-forward proxy in `kubernetes/test/`.

3. Add `apps/<env>/<service>-values.yaml` that patches the base hostname to the
   real one, and reference it from the overlay's `kustomization.yaml`.

The patch file has to declare the same `apiVersion` and `kind` as the resource
it patches. A mismatch does not fail the build, it silently does nothing, which
is how `beszel` went missing its route.

4. Add the app to `kubernetes/apps/<env>/kustomization.yaml` resources.
