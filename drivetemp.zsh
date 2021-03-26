#!/usr/bin/env zsh

# Change the max temp threshold to whatever you like
HDDMAX=40
SSDMAX=60
TMPFILE=$(mktemp)
EMAIL=$(awk '{ if ($1 == "root\:") {print $2 } }' /etc/aliases)
HOSTNAME=$(hostname)
BOUNDARY=$(date +%s | md5 | cut -b1-16)
HDD=( $(smartctl --scan | grep -E 'da|nvme' | cut -d ' ' -f1) )


function tempShell () {
rows="%-22b %-34b %-2b\n"
sep=$(printf "%.s=" {1..54})
printf "%s\n" "$sep"
printf "$rows" "\e[37mDevice" "\e[37mSerial" "\e[37mTemp\e[m"
printf "%s\n" "$sep"

for i in "${HDD[@]}"; do
    TEMP=$(smartctl --json=g -A "$i" | grep 'json.temperature.current' | cut -d ' ' -f3 | tr -d \;)
    SN=$(smartctl --json=g -i "$i" | grep 'json.serial_number' | cut -d ' ' -f3 | tr -d \"\;)
    TYPE=$(smartctl --json=g -a "$i" | grep 'json.rotation_rate' | cut -d ' ' -f3 | tr -d \;)
    if [[ $TEMP -ne 0 ]]; then
        if [[ $TEMP -ge $SSDMAX && $TYPE -eq 0 || $TEMP -ge $HDDMAX && $TYPE -gt 0 ]]; then
          printf "$rows" "\e[37m$i" "\e[90m$SN" "\e[91;5m$TEMP\e[m"
        else
          printf "$rows" "\e[37m$i" "\e[90m$SN" "\e[96m$TEMP\e[m"
        fi
      else
        printf "$rows" "\e[37m$i" "\e[90m$SN" "\e[93mNA\e[m"
    fi
done
}


function tempEmail () {
if [[ "$EMAIL" == "None" ]]; then
    printf "%s\n" "Email is not configured for root user" "Please configure and run again" "exiting..."
    exit 1
fi

{
printf "To: %s\n" "$EMAIL"
printf "Subject: TrueNAS %s: Drive Temp report on %s\n" "$HOSTNAME" "$HOSTNAME"
printf "%s\n" "MIME-Version: 1.0"
printf "Content-Type: multipart/alternative; boundary=%s\n" "$BOUNDARY"
printf "%s\n" --"$BOUNDARY" "Content-Type: text/html; charset=\"utf-8\"" "Content-Transfer-Encoding: 8bit"
printf "%s\n" "<html xmlns=\"http://www.w3.org/1999/xhtml\">" "<body style=\"color:#121212; background-color:#FFFFFF\">" "<table style=\"text-align:left;\">"
printf "%s\n" "<tr>" "<th style=\"width:22ch;\">Device</th>" "<th style=\"width:34ch;\">Serial</th>" "<th style=\"width:4ch;\">Temp</th>" "</tr>"
} >> "$TMPFILE"

for i in "${HDD[@]}"; do
    TEMP=$(smartctl --json=g -A "$i" | grep 'json.temperature.current' | cut -d ' ' -f3 | tr -d \;)
    SN=$(smartctl --json=g -i "$i" | grep 'json.serial_number' | cut -d ' ' -f3 | tr -d \"\;)
    TYPE=$(smartctl --json=g -a "$i" | grep 'json.rotation_rate' | cut -d ' ' -f3 | tr -d \;)
    if [[ $TEMP -ne 0 ]]; then
        if [[ $TEMP -ge $SSDMAX && $TYPE -eq 0 || $TEMP -ge $HDDMAX && $TYPE -gt 0 ]]; then
          printf "%s\n" "<tr>" "<td>$i</td>" "<td style=\"color:#696969;\">$SN</td>" "<td style=\"color:#FF1744;\">$TEMP</td>" "</tr>" >> "$TMPFILE"
        else
          printf "%s\n" "<tr>" "<td>$i</td>" "<td style=\"color:#696969;\">$SN</td>" "<td style=\"color:#00E5FF;\">$TEMP</td>" "</tr>" >> "$TMPFILE"
        fi
      else
        printf "%s\n" "<tr>" "<td>$i</td>" "<td style=\"color:#696969;\">$SN</td>" "<td style=\"color:#FFEE58;\">NA</td>" "</tr>" >> "$TMPFILE"
    fi
done

printf "%s\n" "</table>" "</body>" "</html>" >> "$TMPFILE"
sendmail -t < "$TMPFILE"
rm "$TMPFILE"
}


if [[ $1 == "shell" ]]; then
    tempShell
  elif [[ $1 == "email" ]]; then
    tempEmail
  else
    printf "%s\n" "Incorrect option of $1" "Please run again with [email] or [shell]" "exiting..."
fi
