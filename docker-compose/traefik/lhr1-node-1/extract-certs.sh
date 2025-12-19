#!/bin/sh

# This script runs inside the docker container,
# so the paths won't look correct

echo "Copying the tunneled certs to the synced-certs folder"

# Define the list of domains
DOMAINS="
photos.jakerob.pro
jellyfin.jakerob.pro
authentik.lhr1.jakerob.pro
pocket-id.lhr1.jakerob.pro
whoami-tunnel.lhr1.jakerob.pro
karakeep.jakerob.pro
calibre.jakerob.pro
"

for domain in $DOMAINS; do
  echo "Copying $domain"
  cp -r /output/$domain /synced-certs/
done

chown -R ${DOCKER_USER_ID:-2001}:${DOCKER_GROUP_ID:-2001} synced-certs/
