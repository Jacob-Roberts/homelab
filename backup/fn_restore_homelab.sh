#!/bin/sh

# Function to restore the homelab folder
fn_restore_homelab() {
    set -e
    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
        echo "Error: Missing parameters."
        echo "Usage: restore_homelab DATACENTER SERVICE_FOLDER DATA_FOLDER_NAME RESTIC_CONFIG_NAME"
        exit 1
    fi

    # Parameters
    HOMELAB_ROOT="${HOMELAB_ROOT:-$HOME/homelab}"
    DATACENTER="${1}"
    SERVICE_FOLDER="${2}"
    DATA_FOLDER_NAME="${3}"
    RESTIC_CONFIG_NAME="${4}"

    FOLDER_PATH="$SERVICE_FOLDER/$DATA_FOLDER_NAME"

    if [ -d "$FOLDER_PATH" ]; then
        echo "Folder exists. Moving it to config.bak"
        mv "$FOLDER_PATH" "$FOLDER_PATH.bak"
    else
        echo "Folder does not exist."
    fi

    autorestic -c "$HOMELAB_ROOT/backup/$DATACENTER/.autorestic.yml" restore -l "$RESTIC_CONFIG_NAME" --to "$FOLDER_PATH"

    # It's backed up strangely
    mv "$FOLDER_PATH$FOLDER_PATH" "$SERVICE_FOLDER/${DATA_FOLDER_NAME}_TMP"
    rm -rf "$FOLDER_PATH"
    mv "$SERVICE_FOLDER/${DATA_FOLDER_NAME}_TMP" "$FOLDER_PATH"
}
