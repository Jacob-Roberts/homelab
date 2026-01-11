#!/bin/sh

# This script runs inside the docker container,
# so the paths won't look correct

echo "Copying the tunneled certs to the synced-certs folder"

# Define the list of domains
DOMAINS="
photos.jakerob.pro
jellyfin.jakerob.pro
pocket-id.lhr1.jakerob.pro
whoami-tunnel.lhr1.jakerob.pro
karakeep.jakerob.pro
calibre.jakerob.pro
"

for domain in $DOMAINS; do
  echo "Copying $domain"
  cp -r /output/$domain /synced-certs/
done

echo "Done copying certs, setting permissions"

for domain in $DOMAINS; do
  chgrp -R ${DOCKER_GROUP_ID:-2013} "synced-certs/$domain"
  chmod -R g+r synced-certs/
done


