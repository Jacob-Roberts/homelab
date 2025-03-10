# How to use Ansible in my homelab

Navigate to the folder in playbooks that you want to run.

Ensure you have the secret password set in ~/.ansible/homelab-vault-password.txt` (it's in bitwarden).

Run with `ansible-playbook main.yaml`.

If you only want to run with a certain set of computers, use `ansible-playbook -l lhr1-node-1.jakerob.pro main.yaml`

If you only wnat to run a subset of the commands, use the -t flag. `ansible-playbook -t primary main.yaml`

For example, see nut-client, the play's are tagged.

## Run something in the playbooks folder

This is similar, but to run install-docker you could run `ansible-playbook -l iad1-node-3.jakerob.pro install-docker.yaml`
