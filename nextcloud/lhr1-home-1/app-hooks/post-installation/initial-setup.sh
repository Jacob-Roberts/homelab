php occ config:system:set --value=US default_phone_region
php occ config:system:set --value=true allow_local_remote_servers
php occ app:install user_oidc
php occ user_oidc:provider authentik --clientid="$OIDC_CLIENT_ID" --clientsecret="$OIDC_CLIENT_SECRET" --discoveryuri="https://authentik.lhr1.jakerob.pro/application/o/nextcloud/.well-known/openid-configuration" --unique-uid="0"
php occ config:app:set --value=0 user_oidc allow_multiple_user_backends
