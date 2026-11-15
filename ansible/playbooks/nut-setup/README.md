# NUT (UPS) setup

Semaphore template: playbook `ansible/playbooks/nut-setup/main.yaml`, with an
environment that sets the secrets `NUT_UPS_ADMIN_PASSWORD` and
`NUT_CLIENT_PASSWORD`. Run it once per site:

| Extra variables | Limit |
| --- | --- |
| `{"site": "pbj"}` | `pbj-pi-1,pbj-hv-1` |
| `{"site": "slc1"}` | `slc1-pi-1,slc1-hv-1` |

Tags `primary` or `client` run only the server or the client play.
