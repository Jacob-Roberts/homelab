variable "PM_API_TOKEN_ID" {
  description = "Proxmox API Token ID"
  type        = string
}

variable "PM_API_TOKEN_SECRET" {
  description = "Proxmox API Token secret"
  type        = string
  sensitive   = true
}

variable "lhr1-node-1-mac-address" {
  description = "MAC address of the lhr1-node-1"
  type = string
  sensitive = true
}

variable "lhr1-node-2-mac-address" {
  description = "MAC address of the lhr1-node-2"
  type = string
  sensitive = true
}

variable "lhr1-node-2-root-password" {
  description = "Root password for lhr1-node-2"
  type = string
  sensitive = true
}