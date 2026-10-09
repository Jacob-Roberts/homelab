# Talos — prod

Everything needed to (re)build the `prod` Talos cluster lives here. The
**only** secret is the Talos secrets bundle; it is stored in Infisical under
`/pbj/k8s-talos/prod` as `TALOS_SECRETS`, never in git.

Everything else is derived from that bundle and generated on demand:

| File                     | Source                        | Committed? |
| ------------------------ | ----------------------------- | ---------- |
| `secrets.yaml`           | `talosctl gen secrets`        | No — in Infisical |
| `controlplane.yaml`      | derived (`gen`)               | No         |
| `worker.yaml`            | derived (`gen`)               | No         |
| `talosconfig`            | derived (`gen`)               | No         |
| `talos-patch.yaml`       | hand-written config patch     | **Yes**    |
| `_out/`                  | generated output directory    | No         |

`controlplane.yaml`, `worker.yaml` and `talosconfig` all embed cluster PKI, so
they are treated as secrets too. They are gitignored and rebuilt from the
bundle whenever they are needed. The patch files are the only thing you edit
by hand.

> This directory lives outside `kubernetes/clusters/` on purpose: it is not a
> Kubernetes manifest and Flux must never try to apply it.

## Prerequisites

- `talosctl` and `infisical` (both pinned in the repo's `mise.toml`, so
  `mise install` is enough).
- Infisical access, either interactively (`infisical login`) or via a machine
  identity token in `INFISICAL_TOKEN`.

## First time (new cluster)

1. Create the secret path `/global/talos/prod` in Infisical and upload a fresh
   secrets bundle:

   ```sh
   ./talos.sh secrets-init
   ```

   This runs `talosctl gen secrets` and writes it to Infisical as
   `TALOS_SECRETS`. Keep an offline copy too — without the bundle the cluster
   cannot be recovered.

2. Generate the machine configs:

   ```sh
   ./infisical-run.sh ./talos.sh gen
   ```

3. Apply the config to each node for the first time (nodes are in maintenance
   mode, so this uses the insecure endpoint):

   ```sh
   ./infisical-run.sh ./talos.sh apply-insecure
   ```

4. Bootstrap etcd on the first control plane node (once, after it is up):

   ```sh
   ./infisical-run.sh ./talos.sh bootstrap
   ```

5. Fetch the kubeconfig:

   ```sh
   ./infisical-run.sh ./talos.sh kubeconfig
   ```

## Day-2 changes

1. Edit `talos-patch.yaml` (or add another patch and pass it via `PATCH`).
2. Regenerate and roll it out:

   ```sh
   ./infisical-run.sh ./talos.sh gen
   ./infisical-run.sh ./talos.sh apply
   ```

   `apply` uses the generated `talosconfig`; `apply-insecure` is only for the
   very first apply to a node in maintenance mode.

## Configuration

Non-secret settings live at the top of `talos.sh` and can be overridden with
environment variables:

| Variable            | Default                    | Purpose                              |
| ------------------- | -------------------------- | ------------------------------------ |
| `TALOS_CLUSTER`     | `pbj-prod`                 | Talos cluster name                   |
| `TALOS_ENDPOINT`    | `https://192.168.42.10:6443` | Kubernetes API endpoint (VIP/node) |
| `CONTROLPLANE_NODES`| `192.168.42.10`            | Space-separated control plane IPs    |
| `WORKER_NODES`      | *(empty)*                  | Space-separated worker IPs           |
| `PATCH`             | `talos-patch.yaml`         | Config patch passed to `gen config`  |
| `OUT_DIR`           | `_out`                     | Generated output directory           |
| `INFISICAL_PATH`    | `/global/talos/prod`       | Infisical path of the bundle         |
| `INFISICAL_KEY`     | `TALOS_SECRETS`            | Infisical key of the bundle          |

For separate control plane / worker patches, call `talosctl gen config`
directly with `--config-patch-control-plane @cp.yaml --config-patch-worker
@worker.yaml`.

## Notes

- `talos-patch.yaml` disables the default CNI and kube-proxy because this
  cluster runs Cilium.
- Adding a *new* worker node: append its IP to `WORKER_NODES`, boot the node,
  then `./infisical-run.sh ./talos.sh apply-insecure`.
- Rotating the bundle (`talosctl gen secrets`) invalidates every machine
  config and requires a full re-apply; only do it if the bundle is suspected
  compromised, and keep etcd quorum in mind.
