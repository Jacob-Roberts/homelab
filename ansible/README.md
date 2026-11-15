# Ansible

Ansible prepares hosts; it does not deploy apps. Every Docker host runs
[doco-cd](https://doco.cd), which deploys its stacks from
`docker/clusters/<cluster>/.doco-cd.yml` on `main`. Hosts need no checkout of
this repo.

Ansible's job on a Docker host is the layer underneath doco-cd: admin users,
SSH hardening, Docker Engine and `daemon.json`, service accounts with fixed
IDs, NFS mounts, and the one-time doco-cd bootstrap.

## Setup

Run everything from this directory, so `ansible.cfg` is picked up:

```zsh
cd ansible
ansible-galaxy install -r requirements.yml   # roles/ and collections/, gitignored
```

Public keys for `admin_users` go in `ssh_keys/<name>.pub` (gitignored).

## Layout

| Path | What |
| --- | --- |
| `inventory/hosts.yaml` | Hosts and groups |
| `inventory/group_vars/all.yaml` | Connection user, admin users, site networks, service-account ID registry |
| `inventory/group_vars/docker.yaml` | Docker Engine + `daemon.json` |
| `inventory/group_vars/hardened.yaml` | SSH hardening / unattended upgrades |
| `inventory/host_vars/<host>.yaml` | `doco_cd_cluster`, `service_accounts`, `nfs_mounts` |

Groups:

- `docker`: hosts managed by doco-cd. Each needs `doco_cd_cluster`.
- `hardened`: `docker` + `raspberry_pis`; get admin users and SSH hardening.
- `hypervisors`: Proxmox. Deliberately not `hardened` (cluster needs root SSH).
- `netbird`, `qemu`, `updatable_apt`, `nut_*`: per-feature.

## Playbooks

| Playbook | Hosts | Does |
| --- | --- | --- |
| `site.yaml` | all of the below | Full setup of a host, in order |
| `bootstrap-users.yaml` | `hardened` | First run on a new host: admin users, keys, sudo |
| `security.yaml` | `hardened` | geerlingguy.security + no agent forwarding |
| `docker.yaml` | `docker` | Docker CE, `daemon.json`, subnet-overlap check |
| `service-users.yaml` | `docker` | Fixed-ID service users/groups |
| `nfs-mounts.yaml` | `docker` | TrueNAS NFS mounts |
| `doco-cd.yaml` | `docker` | Client secret, docker-socket-proxy, one-time bootstrap |
| `netbird.yaml` | `netbird` | NetBird client package |
| `qemu-guest-agent.yaml` | `qemu` | Proxmox guest agent |
| `zsh.yaml` | `hardened` | zsh + dotfiles for `jacobroberts` |
| `install-infisical.yaml` | all | Infisical CLI |
| `update-aptpackages/main.yaml` | `updatable_apt` | apt upgrade, Discord alert on pending reboot |
| `check-diskspace/main.yaml` | all | Discord alert when `/` is over 80% |
| `cleanup-docker/main.yaml` | `docker` | Prune dangling images, build cache, non-Compose containers |
| `nut-setup/main.yaml` | `nut_*` | UPS server/clients (see its README) |

The four directory-style playbooks keep their paths for scheduled Semaphore
jobs.

Always preview against a live host first:

```zsh
ansible-playbook playbooks/docker.yaml -l iad1-node-1 --check --diff
```

## Adding a host

1. Add it to `inventory/hosts.yaml` and the right groups. For a Docker host,
   create `inventory/host_vars/<host>.yaml` with `doco_cd_cluster` and
   `service_accounts`, and add `docker/clusters/<cluster>/`.
2. Create the admin users, connecting as the image's default user
   (inventory vars beat `-u`, so use `-e`):
   ```zsh
   ansible-playbook playbooks/bootstrap-users.yaml -l <host> -e ansible_user=ubuntu
   ```
3. Join NetBird by hand (`netbird up --setup-key ...`) once `netbird.yaml`
   has installed it, if the host is reached over the VPN.
4. Run the rest. The Infisical client secret is only needed the first time:
   ```zsh
   DOCO_CD_INFISICAL_CLIENT_SECRET=... ansible-playbook playbooks/site.yaml -l <host>
   ```

## Secrets

No Ansible Vault. Playbooks read secrets from the environment, so they never
land in the repo or on the command line:

| Variable | Used by |
| --- | --- |
| `DOCO_CD_INFISICAL_CLIENT_SECRET` | `doco-cd.yaml` (only when the file is missing, or `-e doco_cd_rotate_secret=true`) |
| `DISCORD_WEBHOOK_URL` | `update-aptpackages`, `check-diskspace` |
| `NUT_UPS_ADMIN_PASSWORD`, `NUT_CLIENT_PASSWORD` | `nut-setup` |

## Docker address pools

Docker's built-in pools end with `192.168.0.0/16` cut into /20s. A host with
more than 15 networks starts handing those out, and one that overlaps a site
LAN makes the host treat that LAN as local: traffic to it never reaches
NetBird. That is how `192.168.32.0/20` on iad1 broke `auth.jakerob.pro`
(the Kubernetes Gateway is `192.168.42.200`).

`group_vars/docker.yaml` replaces that last pool with `10.203.0.0/16` in /24s,
and `docker.yaml` fails if any network overlaps `site_networks` (or a host's
`host_networks`).

### Migrating Docker networks

New pools only apply to new networks. For each network the check reports:

```zsh
N=joplin_frontend; P=joplin        # network, and the Compose project that owns it
T=$(docker ps -q --filter label=com.docker.compose.service=traefik-external)
docker network inspect $N -f '{{range .Containers}}{{.Name}} {{end}}'
docker network disconnect $N $T     # traefik joins app frontends as external
docker compose -p $P down           # keeps volumes; never add -v
docker network rm $N 2>/dev/null
```

doco-cd recreates the project on its next poll (restart the doco-cd container
to force it), then reconnect traefik with `docker network connect $N $T`.
Re-run `docker.yaml` to confirm nothing overlaps.

Leave `docker-socket-proxy` alone unless it overlaps: doco-cd talks to Docker
through it. `docker_gwbridge` is a Swarm leftover; if
`docker info --format '{{.Swarm.LocalNodeState}}'` is `inactive`, remove it.
