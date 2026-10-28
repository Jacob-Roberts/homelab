#!/bin/bash

set -e

# Pass through any arguments to the infisical run command, which will execute the given command with the secrets from the specified path in Infisical.
# Prod is explicit: the repo default environment is "stage" so an accidental
# `infisical run` can never reach production secrets.
infisical run --env=prod --path="/global/terraform/pbj-proxmox-node-1" -- "$@"
