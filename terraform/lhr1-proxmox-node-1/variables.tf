variable "PM_API_TOKEN_ID" {
  description = "Proxmox API Token ID"
  type        = string
  nullable = false
  validation {
    condition     = length(var.PM_API_TOKEN_ID) > 0
    error_message = "PM_API_TOKEN_ID must be a non-empty string."
  }
}

variable "PM_API_TOKEN_SECRET" {
  description = "Proxmox API Token secret"
  type        = string
  sensitive   = true
  nullable = false
  validation {
    condition     = length(var.PM_API_TOKEN_SECRET) > 0
    error_message = "PM_API_TOKEN_SECRET must be a non-empty string."
  }
}

variable "lhr1-node-1-mac-address" {
  description = "MAC address of the lhr1-node-1"
  type = string
  sensitive = true
  nullable = false
  validation {
    condition     = length(var.lhr1-node-1-mac-address) > 0
    error_message = "lhr1-node-1-mac-address must be a non-empty string."
  }
}

variable "lhr1-node-2-mac-address" {
  description = "MAC address of the lhr1-node-2"
  type = string
  sensitive = true
  nullable = false
  validation {
    condition     = length(var.lhr1-node-2-mac-address) > 0
    error_message = "lhr1-node-2-mac-address must be a non-empty string."
  }
}

variable "lhr1-node-2-root-password" {
  description = "Root password for lhr1-node-2"
  type = string
  sensitive = true
  nullable = false
  validation {
    condition     = length(var.lhr1-node-2-root-password) > 0
    error_message = "lhr1-node-2-root-password must be a non-empty string."
  }
}