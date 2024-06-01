#!/bin/sh

set -e

docker compose exec -T postgres  pg_dumpall -c -U authentik-prod-1-admin | bzip2 --best > backups/dump_$(date +%Y-%m-%d_%H_%M_%S).sql.bz2
