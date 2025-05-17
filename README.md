## Warning 
There is a bug in grub 2.06 that will render machines unbootable when you take snapshot of bpool
https://bugs.launchpad.net/ubuntu/+source/grub2-unsigned/+bug/2051999

```bash
# Clone the private repository (use HTTPS or SSH)
# Option 1: Using HTTPS (you’ll be prompted for username/token)
git clone https://github.com/induslevel/sanoid-backup-recovery.git

# Option 2: Using SSH (requires SSH key setup with GitHub)
# git clone git@github.com:induslevel/sanoid-backup-recovery.git

# If already cloned and you want to pull latest changes
cd sanoid-backup-recovery
git pull

# Install sanoid
sudo apt-get install sanoid -y

# Go to the directory with your files
cd files

# Make sure the script is executable
chmod +x sync-zfs-backups.sh

# Copy the backup script to /usr/local/bin
cp sync-zfs-backups.sh /usr/local/bin/

# Copy sanoid configuration
mkdir /etc/sanoid/
cp sanoid.conf /etc/sanoid/

# Copy systemd service and timer files
cp syncoid-backup.service /etc/systemd/system/syncoid-backup.service
cp syncoid-backup.timer /etc/systemd/system/syncoid-backup.timer

# Reload systemd and enable sanoid timer
systemctl daemon-reload
systemctl enable sanoid.timer
systemctl start sanoid.timer
systemctl status sanoid.service

# Reload systemd and enable syncoid backup timer and service
systemctl daemon-reload
systemctl enable syncoid-backup.timer
systemctl enable syncoid-backup.service
systemctl start syncoid-backup.service &
```


## Recovery Steps After GRUB Bug (Unbootable System Fix)
If your machine becomes unbootable due to the GRUB bug after snapshotting bpool, follow these steps after booting from livecd:

```bash
# Import the damaged pool forcibly
zpool import -f bpool

# Backup the current boot contents
mkdir /tmp/boot_backup
rsync -avh /boot/ /tmp/boot_backup/

# Identify existing BOOT dataset
zfs list | grep bpool/BOOT
OLD_BOOT_DATASET=$(zfs list -r -H -o name bpool/BOOT | grep 'ubuntu_')
echo $OLD_BOOT_DATASET

UUID=${OLD_BOOT_DATASET#bpool/BOOT/ubuntu_}
echo "Identified UUID: $UUID"

# Destroy and recreate the bpool with known-safe GRUB features
zpool destroy bpool

zpool create -f \
    -o ashift=12 \
    -o autotrim=on \
    -o cachefile=/etc/zfs/zpool.cache \
    -o feature@async_destroy=enabled \
    -o feature@empty_bpobj=enabled \
    -o feature@lz4_compress=enabled \
    -o feature@multi_vdev_crash_dump=disabled \
    -o feature@spacemap_histogram=enabled \
    -o feature@enabled_txg=enabled \
    -o feature@hole_birth=enabled \
    -o feature@extensible_dataset=disabled \
    -o feature@embedded_data=enabled \
    -o feature@bookmarks=disabled \
    -o feature@filesystem_limits=disabled \
    -o feature@large_blocks=disabled \
    -o feature@large_dnode=disabled \
    -o feature@sha512=disabled \
    -o feature@skein=disabled \
    -o feature@edonr=disabled \
    -o feature@userobj_accounting=disabled \
    -o feature@encryption=disabled \
    -o feature@project_quota=disabled \
    -o feature@device_removal=disabled \
    -o feature@obsolete_counts=disabled \
    -o feature@zpool_checkpoint=disabled \
    -o feature@spacemap_v2=disabled \
    -o feature@allocation_classes=disabled \
    -o feature@resilver_defer=disabled \
    -o feature@bookmark_v2=disabled \
    -o feature@redaction_bookmarks=disabled \
    -o feature@redacted_datasets=disabled \
    -o feature@bookmark_written=disabled \
    -o feature@log_spacemap=disabled \
    -o feature@livelist=disabled \
    -o feature@device_rebuild=disabled \
    -o feature@zstd_compress=disabled \
    -o feature@draid=disabled \
    -o compatibility=grub2 \
    -O devices=off \
    -O acltype=posixacl \
    -O xattr=sa \
    -O compression=lz4 \
    -O normalization=formD \
    -O relatime=on \
    -O canmount=off -O mountpoint=/boot -R /mnt \
    bpool mirror /dev/sda4 /dev/sdb4

# Recreate datasets and restore boot files
zfs create -o canmount=off -o mountpoint=none bpool/BOOT
zfs create -o mountpoint=/boot bpool/BOOT/ubuntu_$UUID
zfs list

rsync -avz /tmp/boot_backup/ /mnt/boot/

# Export bpool
zpool export bpool

# Import rpool and bpool into temporary root
SYSROOT="/mnt"
zpool import -f -R "${SYSROOT}" rpool
zpool import -f -R "${SYSROOT}" bpool

# Mount system filesystems for chroot
mount --rbind /dev "${SYSROOT}/dev"
mount --rbind /proc "${SYSROOT}/proc"
mount --rbind /sys "${SYSROOT}/sys"

# Enter chroot
chroot "${SYSROOT}" /bin/bash

# Update bootloader
update-initramfs -u -k all
update-grub
```
