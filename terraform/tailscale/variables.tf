# Tailscale Credentials
# ---
# Credential Variables needed for Tailscale

variable "tailscale_oauth_client_id" {
  description = "The OAuth application's ID when using OAuth client credentials."
  type        = string
  sensitive   = false
  ephemeral   = true
}

variable "tailscale_oauth_client_secret" {
  description = "The OAuth application's secret when using OAuth client credentials."
  type        = string
  sensitive   = true
  ephemeral   = true
}
