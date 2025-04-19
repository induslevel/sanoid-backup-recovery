#!/bin/bash
set -e

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

# Sync bpool
BPOOL_SRC=$(zfs list -H -o name | grep "^bpool/BOOT/" | head -n1)
sync_dataset "$BPOOL_SRC" "raidpool/zfs-backups/${HOSTNAME}/${BPOOL_SRC}"

# Sync rpool ROOT
RPOOL_SRC=$(zfs list -H -o name | grep "^rpool/ROOT/" | head -n1)
sync_dataset "$RPOOL_SRC" "raidpool/zfs-backups/${HOSTNAME}/${RPOOL_SRC}"

# Sync all rpool/USERDATA datasets
for USERDATA in $(zfs list -H -o name | grep "^rpool/USERDATA/"); do
    sync_dataset "$USERDATA" "raidpool/zfs-backups/${HOSTNAME}/${USERDATA}"
done

