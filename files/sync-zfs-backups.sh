#!/bin/bash

set -e

# Get the current machine's hostname
HOSTNAME=$(hostname)

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

# Auto-detect bpool dataset
BPOOL_SRC=$(zfs list -H -o name | grep "^bpool/BOOT/")
# Auto-detect rpool dataset
RPOOL_SRC=$(zfs list -H -o name | grep "^rpool/ROOT/")

# Sync bpool
sync_dataset "$BPOOL_SRC" "raidpool/zfs-backups/${HOSTNAME}/${BPOOL_SRC}"

# Sync rpool
sync_dataset "$RPOOL_SRC" "raidpool/zfs-backups/${HOSTNAME}/${RPOOL_SRC}"

