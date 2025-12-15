#!/bin/sh

if [ -z "$1" ]; then
  echo "Error: Missing parameters."
  echo "Usage: restore-db dump_asdfasdf.sql"
  exit 1
fi

bzip2 -cdk $1 | docker compose exec -T postgres psql -U authentik-prod-1-admin -d authentik-prod-1

