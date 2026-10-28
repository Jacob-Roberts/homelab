# Agent Guardrails

This repository is a homelab managed with GitOps (Flux), Terraform, and
Infisical. An agent may have broad command access, but production must never
be affected by experimentation. Follow these rules.

## Branching

- `main` is production. Never push to `main` directly. Never force-push.
- Agents open PRs directly to `main`. CI (validate, trivy, ephemeral e2e)
  gates merge; a human reviews and merges. No staging branch is required.
- A `stage` cluster is optional for integration testing only. If used,
  Flux tracks `stage`. The e2e workflow spins up an ephemeral Talos cluster in
  CI, and `scripts/k8s-local/` covers offline checks.
- Do all work on a feature branch (`agent/<topic>` or `t3/<id>`).
- Prod changes only happen by merging a PR into `main`.
- Before touching prod paths, open a PR and wait for review + CI green.

## Environments / Secrets

- Default Infisical environment is `stage`. Do NOT request or use `prod`
  secrets. If a command needs prod, it will fail. You only have access to `stage`.
- Never print, log, or commit secrets. `.env` files are gitignored.
- Infisical run scripts pass `--env=prod` explicitly for real deploys; do not
  remove that flag.

## Testing before prod

- Run `kubernetes/scripts/validate.sh` for manifest changes.
- Run `terraform fmt -check` and `terraform validate` for Terraform.
- For Kubernetes changes, prefer the stage cluster / e2e workflow before prod.
- Local cluster testing: `scripts/k8s-local/talos-up.sh` / `talos-down.sh`
  (requires Docker; mirrors the CI e2e Talos-in-Docker setup).

## Protected paths (require human review)

- `kubernetes/clusters/prod/`, `kubernetes/apps/prod/`
- `terraform/`
- `.github/`, `.github/CODEOWNERS`
- Any `compose.*prod*` or production node overrides

## If unsure

Ask before modifying production state. Prefer staging.
