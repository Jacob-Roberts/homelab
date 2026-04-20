# Cloudflare Credentials
# ---
# Credential Variables needed for Cloudflare

variable "cloudflare_api_token" {
  description = "The API token for your Cloudflare account"
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "cloudflare_account_id" {
  description = "The account ID for your Cloudflare account"
  type        = string
  sensitive   = true
}
