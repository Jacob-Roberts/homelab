php occ config:system:set --value=US default_phone_region
php occ config:system:set --value=true allow_local_remote_servers
php occ app:install user_oidc
php occ user_oidc:provider authentik --clientid="$OIDC_CLIENT_ID" --clientsecret="$OIDC_CLIENT_SECRET" --discoveryuri="https://authentik.lhr1.jakerob.pro/application/o/nextcloud/.well-known/openid-configuration" --mapping-uid="sub" --mapping-quota="quota" --mapping-groups="groups" --unique-uid="0"
PROVIDER_ID=$(php occ user_oidc:provider --output json "authentik" | python3 -c 'import json; p = json.loads(input()); print(p["id"])')
php occ config:app:set user_oidc "provider-${PROVIDER_ID}-groupProvisioning" --value 1
php occ config:app:set --value=0 user_oidc allow_multiple_user_backends
php occ config:system:set --value=4 maintenance_window_start
