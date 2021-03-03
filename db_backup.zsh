#!/usr/bin/env zsh


BAK_DIR="PUT FULL BACKUP PATH HERE"
DB="/data/freenas-v1.db"
VERSION=$(cat /etc/version | cut -d ' ' -f1)
DATE=$(date +%Y-%m-%d)
BAK_FILE="$BAK_DIR"/"$DATE"-"$VERSION".db
cp "$DB" "$BAK_FILE"
find "$BAK_DIR" -type f -mtime +60d -name "*.db" -exec rm {} \;
