# Create a new VM

To create a new VM, only use terraform and ansible.

## Create the VM

Using terraform, create a new VM.

```sh
cd terraform/lhr1-proxmox-node-1/
tofu plan
tofu apply
```

## Setup the VM

After it's setup, you should do everything via ansible

### Bootstrap your new user, then do everything from that user

Edit the inventory file to be able to ssh to the server using the bootstrap user (i.e. "ubuntu")

```diff
---
all:
  hosts:
+    lhr1-node-1:
+      ansible_user: ubuntu
```

Then run the bootstrap command

```sh
cd ansible/playbooks/bootstrap
ansible-playbook main.yaml -l lhr1-node-1
```

### Now finish setup using your admin user

Change the inventory file to now have your real username

```diff
---
all:
  hosts:
    lhr1-node-1:
-      ansible_user: ubuntu
+      ansible_user: jacobroberts
```

```sh
cd ansible/playbooks/homelab-initial-setup
ansible-playbook main.yaml -l lhr1-node-1
```
