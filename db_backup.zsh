#!/usr/bin/env zsh

# Make a backup of the TrueNAS database and secrets file in tar format that can be uploaded through the gui

# Change the BAKDIR to whatever backup directory you are using
BAKDIR="/mnt/deadpool/backups/"
DATADIR="/data"
VERSION=$(cut -d ' ' -f1 /etc/version)
DATE=$(date +%Y%m%d)

tar -C $DATADIR -cvf "$BAKDIR"/"$VERSION"-"$DATE".tar pwenc_secret freenas-v1.db
find "$BAKDIR" -type f -mtime +60d -name "*.tar" -exec rm {} \;
