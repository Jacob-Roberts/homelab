#!/bin/sh

# Exit immediately if a command exits with a non-zero status
set -e
# Treat unset variables as an error
set -u

HOMELAB_ROOT="${HOMELAB_ROOT:-$HOME/homelab}"

docker compose -f $HOMELAB_ROOT/nextcloud/lhr1-node-1/compose.yaml exec --user www-data app php occ maintenance:mode --on

autorestic backup -l nextcloud-files -c $HOMELAB_ROOT/backup/lhr1-node-1/.autorestic.yml
autorestic backup -l nextcloud-db -c $HOMELAB_ROOT/backup/lhr1-node-1/.autorestic.yml

docker compose -f $HOMELAB_ROOT/nextcloud/lhr1-node-1/compose.yaml exec --user www-data app php occ maintenance:mode --off
