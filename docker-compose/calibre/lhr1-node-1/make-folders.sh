#!/bin/bash

set -e

# Get the directory of this script for reliable path resolution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/../../make-folders.sh" "${DOCKER_USER_ID:-2006}:${DOCKER_USER_ID:-2006}" "${DOCKER_DATA_DIR}/calibre" "${DOCKER_DATA_DIR}/calibre/config" "${DOCKER_DATA_DIR}/calibre/ingest" "${DOCKER_DATA_DIR}/calibre/library"
