# GitHub branch protection for the homelab repository.
# Enforces PR-only changes to `main` (production) and `stage`.
terraform {
  required_version = ">= 1.11.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket                      = "jakerob-pro-terraform-state-2"
    key                         = "github/branch-protection.json"
    skip_credentials_validation = true
    skip_region_validation      = true
    endpoint                    = "https://s3.us-west-002.backblazeb2.com"
    region                      = "us-west-002"
    encrypt                     = true
  }
}

provider "github" {
  owner = var.github_owner
  token = var.github_token
}

variable "github_owner" {
  type    = string
  default = "Jacob-Roberts"
}

variable "github_token" {
  type      = string
  sensitive = true
}

variable "repository" {
  type    = string
  default = "homelab"
}

# Production: strict. No direct pushes, PR required, review required,
# status checks required, no force push, no deletion.
resource "github_branch_protection" "main" {
  repository_id = var.repository
  pattern       = "main"

  required_pull_request_reviews {
    required_approving_review_count = 1
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
  }

  # Required status checks are intentionally left empty until the exact check
  # context names are confirmed from a real PR (GitHub Actions names them
  # "<workflow> / <job>"). After the first PR, copy the names from the checks
  # UI into the list below and re-apply.
  required_status_checks {
    strict   = true
    contexts = []
  }

  allows_force_pushes = false
  allows_deletions    = false
  lock_branch         = false
}

# Staging: lighter. PRs encouraged but direct pushes allowed for the agent
# experiment loop; still no force push / deletion.
resource "github_branch_protection" "stage" {
  repository_id = var.repository
  pattern       = "stage"

  allows_force_pushes = false
  allows_deletions    = false
}
