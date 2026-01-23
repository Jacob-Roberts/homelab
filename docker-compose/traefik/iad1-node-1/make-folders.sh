#!/bin/bash

set -e

# Get the directory of this script for reliable path resolution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/../../make-folders.sh" "${DOCKER_USER_ID:-2001}" config-internal/certs/ config-internal/conf/ config-external/certs config-external/static-certs config-external/static-certs-slc1 config-external/plugins config-external/logs config-crowdsec crowdsec-db
