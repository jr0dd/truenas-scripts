#!/usr/bin/env zsh

DOMAIN="xyz.com"
PASSWORD="PASSWORD"
HOST=(www @)
NEWIP=$(curl -s dynamicdns.park-your-domain.com/getip)
OLDIP=$(dig +short "$DOMAIN")

if [[ "$OLDIP" != "$NEWIP" ]]; then
    for i in "${HOST[@]}"; do
        curl -sSo /dev/null "https://dynamicdns.park-your-domain.com/update?host=$i&domain=$DOMAIN&password=$PASSWORD&ip=$NEWIP"
        printf "DNS has been updated on %s for %s to %s\n" "$DOMAIN" "$i" "$NEWIP"
    done
  else
    printf "DNS has not changed on %s\n" "$DOMAIN"
fi
