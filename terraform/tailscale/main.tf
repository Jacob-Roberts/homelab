# Tailscale Provider

terraform {
  required_version = ">= 0.13.0"

  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.19.0"
    }
  }

  backend "s3" {
    bucket                      = "jakerob-pro-terraform-state"
    key                         = "tailscale.json"
    skip_credentials_validation = true
    skip_region_validation      = true
    endpoint                    = "https://s3.us-west-002.backblazeb2.com"
    region                      = "us-west-004"
    # access_key                  = env(AWS_ACCESS_KEY_ID) (backblaze keyID)
    # secret_key                  = env(AWS_SECRET_ACCESS_KEY) (backblaze applicationKey)
    encrypt                     = true
    # sse_customer_key            = env(AWS_SSE_CUSTOMER_KEY) (openssl rand -base64 32)
  }
}

provider "tailscale" {
  oauth_client_id     = var.tailscale_oauth_client_id
  oauth_client_secret = var.tailscale_oauth_client_secret
}