# Cloudflare Credentials
# ---
# Credential Variables needed for Cloudflare

# Cloudflare Config
variable "cloudflare_api_token" {
  description = "The API token for your Cloudflare account"
  type        = string
  sensitive   = true
}

# Cloudflare Account ID
variable "cloudflare_account_id" {
  description = "The account ID for your Cloudflare account"
  type        = string
  sensitive   = true
}
