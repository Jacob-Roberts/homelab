#!/bin/bash

set -e

echo "Enter secret path. (e.g. /iad1-node-1/traefik)"
read secret_path

infisical run --env="prod" --path="$secret_path" -- "$@"
