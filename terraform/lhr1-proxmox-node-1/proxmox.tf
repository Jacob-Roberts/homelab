locals {
  default_ssh_public_keys = file("${path.module}/../ssh_public_keys")
}

# Docs: https://github.com/Telmate/terraform-provider-proxmox/blob/master/docs/resources/lxc.md
resource "proxmox_lxc" "lhr1-node-2" {
  target_node  = "lhr1-hv-2"
  hostname     = "lhr1-node-2"
  ostemplate   = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
  password     = var.lhr1-node-2-root-password
  unprivileged = true
  onboot = true
  startup = "order=1"

  vmid = 100

  cores = 2
  memory = 2048


  ssh_public_keys = local.default_ssh_public_keys

  // Terraform will crash without rootfs defined
  rootfs {
    storage = "local-lvm"
    size    = "20G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
    hwaddr = var.lhr1-node-2-mac-address
  }
}

# Docs: https://github.com/Telmate/terraform-provider-proxmox/blob/master/docs/resources/vm_qemu.md
resource "proxmox_vm_qemu" "lhr1-node-1" {
  name = "lhr1-node-1"
  description = "docker node"
  target_node = "lhr1-hv-2"
  vmid = 200
  start_at_node_boot = true

  agent = 1
  startup_shutdown {
    order = 2
  }

  automatic_reboot = false

  cpu {
    cores    = 4
  }
  # MB
  memory   = 30000

  define_connection_info = false
  scsihw                 = "virtio-scsi-single"

  network {
    id       = 0
    bridge   = "vmbr0"
    model    = "virtio"
    firewall = true
    macaddr = var.lhr1-node-1-mac-address
  }

  disks {
    scsi {
      scsi0 {
        disk {
          size      = "128G"
          storage   = "local-lvm"
          backup    = true
          iothread  = true
          replicate = true
        }
      }
    }
  }
}
