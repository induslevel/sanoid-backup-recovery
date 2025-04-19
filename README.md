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
systemctl start syncoid-backup.service
```

