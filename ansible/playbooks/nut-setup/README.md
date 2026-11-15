# NUT (UPS) setup

Run from `ansible/`, with the NUT passwords in the environment:

```zsh
NUT_UPS_ADMIN_PASSWORD=... NUT_CLIENT_PASSWORD=... \
  ansible-playbook playbooks/nut-setup/main.yaml -e site=pbj -l pbj-pi-1,pbj-hv-1
NUT_UPS_ADMIN_PASSWORD=... NUT_CLIENT_PASSWORD=... \
  ansible-playbook playbooks/nut-setup/main.yaml -e site=slc1 -l slc1-pi-1,slc1-hv-1
```

Use `-t primary` or `-t client` to run only the server or client play.
`requirements.yml` here duplicates `ansible/requirements.yml` for Semaphore.
