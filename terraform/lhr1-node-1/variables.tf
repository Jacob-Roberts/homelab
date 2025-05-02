variable "proxmox_user" {
  description = "Proxmox user. Remember to include the authentication realm such as myuser@pam or myuser@pve."
  type        = string
}

variable "proxmox_pass" {
  description = "Proxmox password"
  type        = string
  sensitive   = true
}
