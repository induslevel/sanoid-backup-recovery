#ZFS Backup using SANOID


##Using the script

Execute the following command to copy the files to respective locations

sudo apt-get install sanoid -y





cd files

cp sync-zfs-backups.sh /usr/local/bin/




cp sanoid.conf /etc/sanoid/

cp syncoid-backup.service /etc/systemd/system/syncoid-backup.service
cp syncoid-backup.timer /etc/systemd/system/syncoid-backup.timer



systemctl daemon-reload
systemctl enable sanoid.timer
systemctl start sanoid.timer
systemctl status sanoid.service

systemctl daemon-reload
systemctl enable syncoid-backup.timer
systemctl enable syncoid-backup.service
systemctl start syncoid-backup.service

