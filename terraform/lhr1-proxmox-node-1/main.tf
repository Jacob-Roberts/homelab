terraform {
  required_version = ">= 0.13.0"

  required_providers {
    proxmox = {
      # LINK https://github.com/Telmate/terraform-provider-proxmox
      source  = "telmate/proxmox"
      version = "3.0.2-rc06"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://proxmox2.lhr1.jakerob.pro:8006/api2/json"
  pm_tls_insecure = true # By default Proxmox Virtual Environment uses self-signed certificates.

  pm_api_token_id     = var.PM_API_TOKEN_ID
  pm_api_token_secret = var.PM_API_TOKEN_SECRET

  # pm_log_enable = true
  # pm_log_file   = "terraform-plugin-proxmox.log"
  # pm_debug      = true
  # pm_log_levels = {
  #   _default    = "debug"
  #   _capturelog = ""
  # }
}