#!/usr/bin/env zsh

# Checks TrueNAS database consistency, and if there's an error, sends an email to the root user

#The command we use to check database consistency
DBCHECK=$(sqlite3 /data/freenas-v1.db 'pragma integrity_check')

if [[ "$DBCHECK" == "ok" ]]; then
    echo Database Check OK
  else
    echo Database Check FAILED!
    TMPFILE=$(mktemp)
    EMAIL=$(awk '{ if ($1 == "root\:") {print $2 } }' /etc/aliases)
    HOSTNAME=$(hostname)
    {
    printf "To: %s\n" "$EMAIL"
    printf "Subject: ERROR: Database corrupt on server %s\n\n" "$HOSTNAME"
    printf "%s has a corrupt TrueNAS config. Please restore from a backup ASAP!\n\n\nErrors:\n\n" "$HOSTNAME"
    printf "%s" "$DBCHECK"
    } >> "$TMPFILE"
    sendmail -t < "$TMPFILE"
    rm "$TMPFILE"
fi
