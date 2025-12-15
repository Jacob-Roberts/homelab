#!/bin/sh

set -e

HOMELAB_ROOT="${HOMELAB_ROOT:-$HOME/homelab}"

docker compose -f $HOMELAB_ROOT/authentik/lhr1-node-1/compose.yaml exec -T postgres  pg_dumpall -c -U authentik-prod-1-admin | bzip2 --best > $HOMELAB_ROOT/authentik/slc1-node-3/backups/dump_$(date +%Y-%m-%d_%H_%M_%S).sql.bz2

echo "successfully backed up authentik DB"
