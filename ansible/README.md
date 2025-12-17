# How to use Ansible in my homelab

Navigate to the folder in playbooks that you want to run.

Ensure you have the secret password set in ~/.ansible/homelab-vault-password.txt` (it's in bitwarden).

Run with `ansible-playbook main.yaml`.

If you only want to run with a certain set of computers, use `ansible-playbook -l lhr1-node-1 main.yaml`

If you only wnat to run a subset of the commands, use the -t flag. `ansible-playbook -t primary main.yaml`

For example, see nut-client, the play's are tagged.

## Run something in the playbooks folder

This is similar, but to run install-docker you could run `ansible-playbook -l iad1-node-3.jakerob.pro install-docker.yaml`


## How to add a secret to ansible vault

To add a new secret to Ansible Vault, do the following:

1. Open (or create) the appropriate secrets file, for example:
   ```
   ansible-vault edit ansible/playbooks/<playbook-folder>/config-secrets.yaml
   ```

2. Enter the vault password when prompted.

3. Add your secret as a YAML key-value pair inside the file. For example:
   ```
   my_new_secret: super_secret_value
   ```

4. Save and exit the editor.

5. In your playbook or role, reference the secret using variable interpolation:
   ```
   {{ my_new_secret }}
   ```

**Tips:**
- Make sure the secrets file is included in `vars_files` in your playbook.
- Never commit vault passwords or unencrypted secrets to version control.
- You can view/edit encrypted files at any time using `ansible-vault edit <file>`.

For more details, see the [Ansible Vault documentation](https://docs.ansible.com/ansible/latest/user_guide/vault.html).
