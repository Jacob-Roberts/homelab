#!/bin/sh

# This script runs inside the docker container,
# so the paths won't look correct

echo "Copying the tunneled certs to the synced-certs folder"

# Define the list of domains
DOMAINS="
photos.jakerob.pro
authentik.lhr1.jakerob.pro
whoami.lhr1.jakerob.pro
"

for domain in $DOMAINS; do
  echo "Copying $domain"
  cp -r /etc/traefik/certs/$domain /synced-certs/
done

chown -R 1000:1000 synced-certs/
