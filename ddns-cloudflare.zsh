#!/usr/bin/env zsh

CF_DNS_API_TOKEN= <<- dns token generated for this zone ->>
CF_ZONEID= <<- zone id ->>
CF_RECORD_NAME= <<- domain.tld ->>

ip4=$(curl -s https://ipv4.icanhazip.com/)

record4=$(curl -s -X GET \
    "https://api.cloudflare.com/client/v4/zones/$CF_ZONEID/dns_records?name=$CF_RECORD_NAME&type=A" \
    -H "Authorization: Bearer $CF_DNS_API_TOKEN" \
    -H "Content-Type: application/json" \
)

old_ip4=$(echo "$record4" | sed -n 's/.*"content":"\([^"]*\).*/\1/p')
if [ "$ip4" = "$old_ip4" ]; then
    printf "%s - Success - IP Address '%s' has not changed" "$(date -u)" "$ip4"
    exit 0
fi

record4_identifier=$(echo "$record4" | sed -n 's/.*"id":"\([^"]*\).*/\1/p')
update4=$(curl -s -X PUT \
    "https://api.cloudflare.com/client/v4/zones/$CF_ZONEID/dns_records/$record4_identifier" \
    -H "Authorization: Bearer $CF_DNS_API_TOKEN" \
    -H "Content-Type: application/json" \
    --data "{\"id\":\"$CF_ZONEID\",\"type\":\"A\",\"proxied\":true,\"name\":\"$CF_RECORD_NAME\",\"content\":\"$ip4\"}" \
)

if echo "$update4" | grep -q '\"success\":false'; then
    printf "%s - Yikes - Updating IP Address '%s' has failed" "$(date -u)" "$ip4"
    exit 1
  else
    printf "%s - Success - IP Address '%s' has been updated" "$(date -u)" "$ip4"
    exit 0
fi
