# GitHub branch protection for the homelab repository.
# Enforces PR-only changes to `main` (production).
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
    # access_key                  = env(AWS_ACCESS_KEY_ID) (backblaze keyID)
    # secret_key                  = env(AWS_SECRET_ACCESS_KEY) (backblaze applicationKey)
    # sse_customer_key            = env(AWS_SSE_CUSTOMER_KEY) (openssl rand -base64 32)
  }
}

provider "github" {
  owner = var.github_owner
  token = var.github_token
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
