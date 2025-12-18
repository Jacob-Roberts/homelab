#!/bin/bash

set -e

DIRS="$1"
SERVICE_ID="$2"

if [ -z "$DIRS" ] || [ -z "$SERVICE_ID"] ; then
    echo "Usage: $0  <service_id> <dir1> <dir2> ..."
    exit 1
fi

mkdir -p $DIRS

chown $SERVICE_ID $DIRS
