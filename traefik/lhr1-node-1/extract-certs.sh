#!/usr/bin/env bash

docker run -v ./config/certs:/certs -v ./certs-dump:/certs-dump ldez/traefik-certs-dumper file --clean --version v3 --source /certs/cloudflare-acme.json --dest /certs-dump