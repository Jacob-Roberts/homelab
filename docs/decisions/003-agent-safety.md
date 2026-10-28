# 003 - Agent safety and production isolation

## Status

Accepted

## Context

AI agents are given broad command access to experiment. Production
deployments (Flux on `main`, prod Infisical env) must not be affected by
experimentation.

## Decision

- `main` = production, protected (PR required, no force push, no deletion).
- Agents open PRs directly to `main`; CI (validate, trivy, ephemeral e2e)
  gates merge and a human reviews.
- A `stage` cluster is optional for integration testing only. Flux for
  any stage cluster tracks `stage`. No persistent staging environment required.
- Infisical default environment changed to `stage`; prod scripts pass
  `--env=prod` explicitly.
- Agent Infisical identity is scoped to staging only (Infisical-side).
- Local testing via kind (`scripts/k8s-local/`); CI e2e on PRs to `main`.
- Branch protection managed by `terraform/github`.

## Consequences

- Accidental `infisical run` can no longer reach prod secrets.
- Stage can be broken freely by agents without affecting prod.
- Prod requires PR + review + green CI.
