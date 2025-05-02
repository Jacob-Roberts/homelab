# Cloudflare Credentials
# ---
# Credential Variables needed for Cloudflare

# Cloudflare Config
variable "cloudflare_api_token" {
    description = "The API token for your Cloudflare account"
    type = string
    sensitive = true
}