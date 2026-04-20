#!/bin/bash

set -e

# Pass through any arguments to the infisical run command, which will execute the given command with the secrets from the specified path in Infisical.
infisical run --path="/global/terraform/iad1" -- "$@"
