#!/bin/sh

HOMELAB_ROOT="${HOMELAB_ROOT:-$HOME/homelab}"

# Source the function from manage_folder.sh
. $HOMELAB_ROOT/backup/fn_restore_homelab.sh

fn_restore_homelab "lhr1-node-1" "$HOMELAB_ROOT/nextcloud/lhr1-node-1" "data" "nextcloud-files"
result=$?

if [ $result -ne 0 ]; then
    echo "restore failed with status $result"
else
    echo "restore succeeded"
fi

sudo chown www-data:www-data -R $HOMELAB_ROOT/nextcloud/lhr1-node-1/data
sudo chown root:root $HOMELAB_ROOT/nextcloud/lhr1-node-1/data/nextcloud-init-sync.lock

autorestic restore -l nextcloud-db -c $HOMELAB_ROOT/backup/lhr1-node-1/.autorestic.yml

echo "Done restoring. Now restart the app and run the following command:"
echo 'docker compose -f $HOMELAB_ROOT/nextcloud/lhr1-node-1/compose.yaml exec --user www-data app php occ maintenance:mode --off'
