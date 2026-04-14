# Cloudflare Credentials
# ---
# Credential Variables needed for Cloudflare

ephemeral "infisical_secret" "cloudflare_api_token" {
  name         = "CLOUDFLARE_API_TOKEN"
  workspace_id = var.infisical_project_id
  env_slug     = var.infisical_env_slug
  folder_path  = "/global/cloudflare/autovation_com"
}

variable "cloudflare_account_id" {
  description = "The account ID for your Cloudflare account"
  type        = string
  sensitive   = true
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
}
