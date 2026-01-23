#!/bin/sh

git pull --prune

HOMELAB_ROOT=$HOME/homelab

cd $HOMELAB_ROOT/cadvisor/lhr1-node-1
docker compose up -d --pull always --remove-orphans

cd $HOMELAB_ROOT/grafana/lhr1-node-1
docker compose up -d --pull always --remove-orphans

cd $HOMELAB_ROOT/homepage/lhr1-node-1
docker compose up -d --pull always --remove-orphans

cd $HOMELAB_ROOT/immich/lhr1-node-1
docker compose up -d --pull always --remove-orphans

cd $HOMELAB_ROOT/jellyfin/lhr1-node-1
docker compose up -d --pull always --remove-orphans

cd $HOMELAB_ROOT/media-management/lhr1-node-1
docker compose up -d --pull always --remove-orphans

cd $HOMELAB_ROOT/minio/lhr1-node-1
docker compose up -d --pull always --remove-orphans

cd $HOMELAB_ROOT/myspeed/lhr1-node-1
docker compose up -d --pull always --remove-orphans

cd $HOMELAB_ROOT/nextcloud/lhr1-node-1
docker compose up -d --pull always --remove-orphans

cd $HOMELAB_ROOT/portainer/lhr1-node-1
docker compose up -d --pull always --remove-orphans

cd $HOMELAB_ROOT/traefik/lhr1-node-1
docker compose up -d --pull always --remove-orphans

cd $HOMELAB_ROOT/uptime-kuma/lhr1-node-1
docker compose up -d --pull always --remove-orphans

cd $HOMELAB_ROOT/webnut/lhr1-node-1
docker compose up -d --pull always --remove-orphans

cd $HOMELAB_ROOT/wordpress-personal/lhr1-node-1
docker compose up -d --pull always --remove-orphans