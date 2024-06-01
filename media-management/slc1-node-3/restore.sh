#!/bin/sh

HOMELAB_ROOT="${HOMELAB_ROOT:-$HOME/homelab}"

# Source the function from manage_folder.sh
. $HOMELAB_ROOT/backup/fn_restore_homelab.sh

fn_restore_homelab "$HOMELAB_ROOT/media-management/slc1-node-3" "config" "media-management-config"
result=$?

if [ $result -ne 0 ]; then
    echo "restore failed with status $result"
else
    echo "restore succeeded"
fi
