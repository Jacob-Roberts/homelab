terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 6.35"
    }
  }
}


provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  private_key_path = var.rsa_private_key_path
  fingerprint      = var.fingerprint
  region           = var.region
}