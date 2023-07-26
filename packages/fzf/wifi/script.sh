#!/usr/bin/env bash

echo "Scanning..."

fields="BSSID,SSID,BARS,SECURITY,IN-USE"
ssids=$(nmcli -f $fields dev wifi list | tail -n +2)
selection="$(printf '%s\n' "${ssids[@]}" | fzf --reverse --prompt='wifi > ')"
tput cuu1
tput el
[[ -n $selection ]] || { printf "Canceled\n" && exit 1; }

ssid=$(printf "$selection" | awk '{ print $2 }')
nmcli --ask device wifi connect "$ssid"
