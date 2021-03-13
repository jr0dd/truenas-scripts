#!/usr/bin/env zsh

# Checks TrueNAS database consistency, and if there's an error, sends an email to the root user

DB="/data/freenas-v1.db"
DBCHECK=$(sqlite3 "$DB" 'pragma integrity_check')
TMPFILE=$(mktemp)
EMAIL=$(awk '{ if ($1 == "root\:") {print $2 } }' /etc/aliases)
HOSTNAME=$(hostname)

if [[ -f "$DB" && "$DBCHECK" == "ok" ]]; then
    printf "Database Check OK"
  else
    if [[ ! -f "$DB" ]]; then
        printf "Database not present. Please check path."
      else
        if [[ "$EMAIL" == "None" ]]; then
            printf "%s\n" "Database error was found, but no email is configured for root user"
            printf "%s\n" "Outputting error to shell only"
            printf "%s\n" "$DBCHECK"
          else
            {
            printf "To: %s\n" "$EMAIL"
            printf "Subject: TrueNAS %s: Alert: DB Check on %s\n" "$HOSTNAME" "$HOSTNAME"
            printf "%s has a corrupt TrueNAS config. Please restore from a backup ASAP!\n\n\nErrors:\n\n" "$HOSTNAME"
            printf "%s" "$DBCHECK"
            } >> "$TMPFILE"
            sendmail -t < "$TMPFILE"
            rm "$TMPFILE"
        fi
    fi
fi
