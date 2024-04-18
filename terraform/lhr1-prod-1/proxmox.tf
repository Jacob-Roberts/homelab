provider "proxmox" {
  pm_api_url  = "https://proxmox.lhr1.jakerob.pro:8006/api2/json"
  pm_user     = var.proxmox_user
  pm_password = var.proxmox_pass
}

resource "proxmox_lxc" "pi_hole" {
  target_node  = "lhr1"
  hostname     = "pi-hole"
  cores        = 2
  memory       = 2048
  swap         = 512
  onboot       = true
  unprivileged = true

  start   = true
  startup = "order=1"

  rootfs {
    storage = ""
    size    = "20G"
  }
}

# import {
#   to = proxmox_lxc.docker-node-2
#   id = "lhr1/lxc/105"
# }

# resource "proxmox_lxc" "docker-node-2" {
#   target_node  = "lhr1"
#   hostname     = "docker-node-2"
#   unprivileged = true

#   // Terraform will crash without rootfs defined
#   rootfs {
#     storage = "local-lvm"
#     size    = "528G"
#   }

#   network {
#     name   = "eth0"
#     bridge = "vmbr0"
#     ip     = "dhcp"
#   }
# }
