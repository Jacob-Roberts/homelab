#!/bin/sh

curl https://api.cloudflare.com/client/v4/zones \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
-H "Content-Type: application/json"
