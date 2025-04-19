#!/bin/bash

set -e

sync_dataset() {
    SRC="$1"
    DST="$2"

    PARENT=$(dirname "$DST")
    if ! zfs list -H -o name "$PARENT" >/dev/null 2>&1; then
        echo "Creating missing parent dataset: $PARENT"
        sudo zfs create -p "$PARENT"
    fi

    echo "Syncing $SRC -> $DST"
    /usr/sbin/syncoid --recursive --no-privilege-elevation "$SRC" "$DST"
}

# Sync bpool
sync_dataset "bpool/BOOT/ubuntu_l8whg0" "raidpool/rpool-backup/BOOT/ubuntu_l8whg0"

# Sync rpool
sync_dataset "rpool/ROOT/ubuntu_l8whg0" "raidpool/rpool-backup/ROOT/ubuntu_l8whg0"

