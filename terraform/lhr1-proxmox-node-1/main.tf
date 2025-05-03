terraform {
  required_version = ">= 0.13.0"
  
  required_providers {
    proxmox = {
      # LINK https://github.com/Telmate/terraform-provider-proxmox
      source = "telmate/proxmox"
      version = "3.0.1-rc8"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://proxmox.lhr1.jakerob.pro:8006/api2/json"
  pm_tls_insecure = true # By default Proxmox Virtual Environment uses self-signed certificates.

  pm_user = var.proxmox_user
  pm_password = var.proxmox_pass

  # pm_log_enable = true
  # pm_log_file   = "terraform-plugin-proxmox.log"
  # pm_debug      = true
  # pm_log_levels = {
  #   _default    = "debug"
  #   _capturelog = ""
  # }
}