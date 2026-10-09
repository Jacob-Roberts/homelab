#!/bin/bash

set -e

# Pass through any arguments to the infisical run command, which will execute the given command with the secrets from the specified path in Infisical.
# For Talos, `talos.sh gen` reads the TALOS_SECRETS environment variable that this injects.
infisical run --path="/pbj/k8s-talos/prod" --projectId="f3732b81-3a85-430d-a547-43b85c363ad6" -- "$@"
