terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 6.35"
    }
  }

  backend "s3" {
    bucket                      = "jakerob-pro-terraform-state"
    key                         = "iad1.json"
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


provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  private_key_path = var.rsa_private_key_path
  fingerprint      = var.fingerprint
  region           = var.region
}