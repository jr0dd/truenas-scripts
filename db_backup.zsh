#!/usr/bin/env zsh

# Make a backup of the TrueNAS database and secrets file in tar format that can be uploaded through the gui

BAKDIR="/mnt/deadpool/backups"
DATADIR="/data"
VERSION=$(cut -d ' ' -f1 /etc/version)
DATE=$(date +%Y%m%d%H%M%S)

tar -C $DATADIR -cf "$BAKDIR"/"$VERSION"-"$DATE".tar pwenc_secret freenas-v1.db
find "$BAKDIR" -type f -mtime +60d -name "*.tar" -exec rm {} \;
