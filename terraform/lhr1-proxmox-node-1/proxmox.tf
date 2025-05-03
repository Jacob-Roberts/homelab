locals {
  default_ssh_public_keys = file("${path.module}/../ssh_public_keys")
}

# resource "proxmox_lxc" "pi_hole" {
#   target_node  = "proxmox"
#   hostname     = "pihole"
#   ostemplate   = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
#   # password     = "BasicLXCContainer"
#   cores        = 2
#   memory       = 2048
#   swap         = 512
#   onboot       = true
#   unprivileged = true

#   start   = true
#   startup = "order=1"

#   ssh_public_keys = local.default_ssh_public_keys

#   rootfs {
#     storage = "local-lvm"
#     size    = "20G"
#   }

#   network {
#     name = "eth0"
#     bridge = "vmbr0"
#     ip = "dhcp"
#   }
# }

resource "proxmox_vm_qemu" "lhr1-node-1" {
  name        = "lhr1-node-1.jakerob.pro"
  desc        = "Real Final LHR1 docker node\nscsi1: local-lvm:vm-100-disk-1,backup=0,iothread=1,replicate=0,size=1500G"
  target_nodes = [
    "proxmox"
  ]

  agent = 1

  vmid = 200

  onboot = true

  startup = "order=2"

  automatic_reboot = false

  cores = 4
  sockets = 1
  cpu_type = "host"
  memory = 14336

  define_connection_info = false
  scsihw = "virtio-scsi-single"

  full_clone = false

  network {
    id = 0
    bridge = "vmbr0"
    model = "virtio"
    firewall = true
  }

  disks {
    scsi {
      scsi0 {
        disk {
          size = "257G"
          storage = "local-lvm"
          backup = true
          iothread = true
          replicate = true
        }
      }
    }
  }
}
