#!/usr/bin/env bash

mkdir -p certs-dump

docker run --rm -v ./config/certs:/certs -v ./certs-dump:/certs-dump ldez/traefik-certs-dumper file --clean --domain-subdir=true --version v3 --source /certs/cloudflare-acme.json --dest /certs-dump

mkdir -p synced-certs

# Define the list of domains
DOMAINS=(
  "photos.jakerob.pro"
  "authentik.lhr1.jakerob.pro"
  "whoami.lhr1.jakerob.pro"
)

for domain in "${DOMAINS[@]}"; do
  sudo cp -f -r ./certs-dump/${domain} synced-certs/
done

sudo chown -R jacobroberts:jacobroberts synced-certs/

sudo rm -rf certs-dump
