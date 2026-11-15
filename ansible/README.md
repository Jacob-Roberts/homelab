# Ansible

Ansible prepares hosts; it does not deploy apps. Every Docker host runs
[doco-cd](https://doco.cd), which deploys its stacks from
`docker/clusters/<cluster>/.doco-cd.yml` on `main`. Hosts need no checkout of
this repo.

Ansible's job on a Docker host is the layer underneath doco-cd: admin users,
SSH hardening, Docker Engine and `daemon.json`, service accounts with fixed
IDs, NFS mounts, and the one-time doco-cd bootstrap.

## Running playbooks (Semaphore)

Every playbook runs from Semaphore (`docker/apps/semaphore`, on pbj-node-1).
What its project needs:

- **Repository**: this repo, branch `main`.
- **Inventory**: type *File*, path `ansible/inventory/hosts.yaml`. It must be
  the repo file, not a copy pasted into Semaphore: `group_vars/` and
  `host_vars/` next to it hold nearly every setting, and Ansible only loads
  them alongside that file.
- **Key**: the SSH key for `ansible-robot`. Its public half goes in
  `admin_users` (`group_vars/all.yaml`), or the security playbook locks it
  out.
- **Environment**: secrets of type *environment variable* (see
  [Secrets](#secrets)).
- **Templates**: playbook paths are relative to the repo root, e.g.
  `ansible/playbooks/docker.yaml`. Limit to one host with the template's
  *Limit* field. Use *Dry run* (`--check`) and *Diff* for a preview.

Semaphore runs from the repo root, so it never reads `ansible/ansible.cfg`;
that file only serves local lint and syntax checks. Before each task it
installs `requirements.yml` from the repo root, which pins every role and
collection here.

Preview before the first real run on a host, especially `docker.yaml`: the
role rewrites `daemon.json` as a whole.

## Layout

| Path | What |
| --- | --- |
| `../requirements.yml` | Roles and collections (repo root, for Semaphore) |
| `inventory/hosts.yaml` | Hosts and groups |
| `inventory/group_vars/all.yaml` | Connection user, admin users and keys, site networks, service-account ID registry |
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

The four directory-style playbooks keep their paths, so existing scheduled
templates keep working.

### Semaphore runs on pbj-node-1

Anything that restarts dockerd there kills the running task unless
`live-restore` is on. `docker.yaml` checks this first on that host
(`docker_runs_semaphore` in its host_vars) and stops before touching
`daemon.json` if it is off.

## Adding a host

1. Add it to `inventory/hosts.yaml` and the right groups. For a Docker host,
   create `inventory/host_vars/<host>.yaml` with `doco_cd_cluster` and
   `service_accounts`, and add `docker/clusters/<cluster>/`. Merge to `main`
   so Semaphore sees it.
2. Make the image's default user accept Semaphore's key (cloud-init or
   `authorized_keys`).
3. Run `bootstrap-users.yaml`, limited to the host, with extra variables
   `{"ansible_user": "ubuntu"}` (or whatever the image's user is).
   Inventory variables beat the login on a Semaphore key, so only an extra
   variable overrides the connection user.
4. Join NetBird by hand (`netbird up --setup-key ...`) once `netbird.yaml`
   has installed it, if the host is reached over the VPN.
5. Run `site.yaml` limited to the host, with `DOCO_CD_INFISICAL_CLIENT_SECRET`
   in the environment. The secret is only read the first time.

## Secrets

No Ansible Vault. Playbooks read secrets from environment variables, which
Semaphore fills from an environment's secrets, so they never land in the repo
or in task logs. Extra variables show up in the Semaphore UI; don't put
secrets there.

| Variable | Used by |
| --- | --- |
| `DOCO_CD_INFISICAL_CLIENT_SECRET` | `doco-cd.yaml` (only when the file is missing, or extra var `{"doco_cd_rotate_secret": true}`) |
| `DISCORD_WEBHOOK_URL` | `update-aptpackages`, `check-diskspace` |
| `NUT_UPS_ADMIN_PASSWORD`, `NUT_CLIENT_PASSWORD` | `nut-setup` |

## Local checks

For linting and syntax checks only, not for changing hosts:

```zsh
cd ansible
ansible-galaxy install -r ../requirements.yml   # into roles/ and collections/, gitignored
ansible-playbook playbooks/site.yaml --syntax-check
ansible-lint playbooks
```

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
Re-run the `docker.yaml` template to confirm nothing overlaps.

Leave `docker-socket-proxy` alone unless it overlaps: doco-cd talks to Docker
through it. `docker_gwbridge` is a Swarm leftover; if
`docker info --format '{{.Swarm.LocalNodeState}}'` is `inactive`, remove it.
