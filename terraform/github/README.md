# GitHub branch protection

Manages branch protection rules for `main` (production) and `stage`.

## Apply

```zsh
cd terraform/github
export GITHUB_TOKEN=...   # or use infisical
terraform init
terraform plan
terraform apply
```

`main` requires a PR with 1 approval, code-owner review, and passing status
checks (`manifests`, trivy). Force push and deletion are disabled.
`stage` allows direct pushes (agent experiment loop) but no force push/deletion.
