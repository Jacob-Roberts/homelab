variable "github_owner" {
  description = "GitHub organization or user that owns the repository."
  type        = string
  default     = "Jacob-Roberts"
}

variable "github_token" {
  description = "GitHub token with repo admin scope for branch protection."
  type        = string
  sensitive   = true
}

variable "repository" {
  description = "Repository name."
  type        = string
  default     = "homelab"
}
