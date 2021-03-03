#!/usr/bin/env zsh

#==================================================================#
#==================================================================#
#   Written by j_r0dd                                              #
#                                                                  #
#   Last updated: 2021-03-02                                       #
#                                                                  #
#   This is a simple script to check drive temperatures manually.  #
#   I use this to test my fan configurations or see where there    #
#   is less than optimal airflow on my drives so I can address.    #
#==================================================================#
#==================================================================#

# Set this to the max temp to be shown in red
MAX=40

# Device array
HDD=( $(smartctl --scan | grep -E 'da|nvme' | cut -d ' ' -f1) )

# Table
rows="%-22b %-34b %-2b\n"
sep=$(printf "%.s=" {1..54})
printf "%s\n" "$sep"
printf "$rows" "\e[37mDevice" "\e[37mSerial" "\e[37mTemp\e[m"
printf "%s\n" "$sep"

for i in "${HDD[@]}"; do
    TEMP=$(smartctl --json=g -A "$i" | grep 'json.temperature.current' | cut -d ' ' -f3 | tr -d \;)
    SN=$(smartctl --json=g -i "$i" | grep 'json.serial_number' | cut -d ' ' -f3 | tr -d \"\;)
    if [[ $TEMP -ne 0 ]]; then
        if [[ $TEMP -ge $MAX ]]; then
          printf "$rows" "\e[37m$i" "\e[90m$SN" "\e[31;5m$TEMP\e[m"
        else
          printf "$rows" "\e[37m$i" "\e[90m$SN" "\e[36m$TEMP\e[m"
        fi
      else
        printf "$rows" "\e[37m$i" "\e[90m$SN" "\e[33mNA\e[m"
    fi
done
