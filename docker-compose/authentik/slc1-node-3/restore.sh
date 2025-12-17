#!/bin/sh

HOMELAB_ROOT="${HOMELAB_ROOT:-$HOME/homelab}"

# Source the function from manage_folder.sh
. $HOMELAB_ROOT/backup/fn_restore_homelab.sh

fn_restore_homelab "slc1-node-3" "$HOMELAB_ROOT/authentik/slc1-node-3" "certs" "authentik-config"
result=$?

if [ $result -ne 0 ]; then
    echo "restore failed with status $result"
else
    echo "restore succeeded"
fi

fn_restore_homelab "slc1-node-3" "$HOMELAB_ROOT/authentik/slc1-node-3" "custom-templates" "authentik-config"
result=$?

if [ $result -ne 0 ]; then
    echo "restore failed with status $result"
else
    echo "restore succeeded"
fi

fn_restore_homelab "slc1-node-3" "$HOMELAB_ROOT/authentik/slc1-node-3" "media" "authentik-config"
result=$?

if [ $result -ne 0 ]; then
    echo "restore failed with status $result"
else
    echo "restore succeeded"
fi
