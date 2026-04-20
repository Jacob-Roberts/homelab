# Tailscale Provider

terraform {
  required_version = ">= 1.11.0"

  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.19.0"
    }

    infisical = {
      source  = "infisical/infisical"
      version = "~> 0.16.15"
    }
  }

  backend "s3" {
    bucket                      = "jakerob-pro-terraform-state-2"
    key                         = "tailscale.json"
    skip_credentials_validation = true
    skip_region_validation      = true
    endpoint                    = "https://s3.us-west-002.backblazeb2.com"
    region                      = "us-west-002"
    # access_key                  = env(AWS_ACCESS_KEY_ID) (backblaze keyID)
    # secret_key                  = env(AWS_SECRET_ACCESS_KEY) (backblaze applicationKey)
    encrypt = true
    # sse_customer_key            = env(AWS_SSE_CUSTOMER_KEY) (openssl rand -base64 32)
  }
}

provider "tailscale" {
  oauth_client_id     = ephemeral.infisical_secret.tailscale_oauth_client_id.value
  oauth_client_secret = ephemeral.infisical_secret.tailscale_oauth_client_secret.value
}

provider "infisical" {
  host = "https://app.infisical.com"

  auth = {
    universal = {
      client_id     = var.infisical_client_id
      client_secret = var.infisical_client_secret
    }
  }
}