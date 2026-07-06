#!/bin/bash

set -e

# Configuration for this service
PROJECT_ID="f3732b81-3a85-430d-a547-43b85c363ad6"
ENVIRONMENT="prod"

echo "Enter secret path. (e.g. /iad1-node-1/traefik)"
read secret_path

# Get the directory of this script for reliable path resolution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Pass through any command line arguments to the main script
# This allows using --force, --backup, etc. from this wrapper
"$SCRIPT_DIR/../get-env-file.sh" "$@" "$PROJECT_ID" "$ENVIRONMENT" "$secret_path"