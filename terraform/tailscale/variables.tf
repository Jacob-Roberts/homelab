# Tailscale Credentials
# ---
# Credential Variables needed for Tailscale

ephemeral "infisical_secret" "tailscale_oauth_client_id" {
  name         = "TAILSCALE_OAUTH_CLIENT_ID"
  description = "The OAuth application's ID when using OAuth client credentials."
  workspace_id = var.infisical_project_id
  env_slug     = var.infisical_env_slug
  folder_path  = "/global/tailscale"
}

ephemeral "infisical_secret" "tailscale_oauth_client_secret" {
  name         = "TAILSCALE_OAUTH_CLIENT_SECRET"
  description = "The OAuth application's secret when using OAuth client credentials."
  workspace_id = var.infisical_project_id
  env_slug     = var.infisical_env_slug
  folder_path  = "/global/tailscale"
}

# Infisical Credentials
# ---
# Credential Variables needed for Infisical

variable "infisical_client_id" {
  description = "Infisical Machine Identity Client ID"
  type        = string
  sensitive   = true
}

variable "infisical_client_secret" {
  description = "Infisical Machine Identity Client Secret"
  type        = string
  sensitive   = true
}

variable "infisical_project_id" {
  description = "Infisical Project ID (formerly workspace_id)"
  type        = string
}

variable "infisical_env_slug" {
  type        = string
  description = "Infisical environment slug (e.g., dev, staging, prod)"
  default     = "prod"
}
