# Homelab Initial Setup

This directory contains Ansible playbooks for the initial setup of a homelab node.

## Structure

```
homelab-initial-setup/
├── ansible.cfg           # Ansible configuration
├── vars/
│   └── main.yaml         # Shared variables for all playbooks
├── playbooks/
│   ├── run-all.yaml      # Runs all playbooks in order
│   ├── 01-security.yaml  # Security & SSH hardening
│   ├── 02-docker.yaml    # Docker installation
│   ├── 03-users-groups.yaml  # Users & groups setup
│   ├── 04-git-repo.yaml  # Git repository setup
│   ├── 05-service-users.yaml # Service users (traefik, jellyfin, etc.)
│   ├── 06-service-permissions.yaml # Directory permissions
│   └── 07-nfs-mounts.yaml # NFS mounts
└── README.md
```

## Usage

### Run everything

```bash
cd ansible/playbooks/homelab-initial-setup
ansible-playbook playbooks/run-all.yaml
```

### Run individual playbooks

```bash
cd ansible/playbooks/homelab-initial-setup

# Security hardening only
ansible-playbook playbooks/01-security.yaml

# Docker installation only
ansible-playbook playbooks/02-docker.yaml

# Users and groups only
ansible-playbook playbooks/03-users-groups.yaml

# Git repo setup only
ansible-playbook playbooks/04-git-repo.yaml

# Service users only
ansible-playbook playbooks/05-service-users.yaml

# Service permissions only
ansible-playbook playbooks/06-service-permissions.yaml

# NFS mounts only
ansible-playbook playbooks/07-nfs-mounts.yaml
```

### Target a different host

By default, playbooks target `lhr1-node-1`. Override with:

```bash
ansible-playbook playbooks/01-security.yaml -e "target_host=slc1-node-3"
```

## Playbook Dependencies

Some playbooks depend on others having been run first:

| Playbook | Dependencies |
|----------|--------------|
| 01-security | None |
| 02-docker | None |
| 03-users-groups | None |
| 04-git-repo | 03-users-groups |
| 05-service-users | None |
| 06-service-permissions | 04-git-repo, 05-service-users |
| 07-nfs-mounts | None |

## Configuration

Edit `vars/main.yaml` to customize:

- Target host
- User accounts
- Service users and UIDs/GIDs
- NFS mount points
- Security settings
- Docker configuration

## Required Ansible Galaxy Roles

```bash
ansible-galaxy install geerlingguy.security geerlingguy.docker
```

