#!/bin/bash

set -e

echo "Enter secret path"
read secret_path

infisical run --env="prod" --path="$secret_path" -- "$@"
