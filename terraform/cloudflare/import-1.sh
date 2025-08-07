#!/bin/sh

curl https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_IMPORT_ZONE_ID/dns_records \
    -H "Authorization: Bearer $CLOUDFLARE_TOKEN" \
-H "Content-Type: application/json" > dns.json
