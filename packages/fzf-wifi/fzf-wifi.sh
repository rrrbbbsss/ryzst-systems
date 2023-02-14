#!/usr/bin/env bash

echo "Scanning..."

fields="BSSID,SSID,BARS,SECURITY,IN-USE"
ssids=$(nmcli -f $fields dev wifi list | tail -n +2)
selection=$(printf '%s\n' "${ssids[@]}" | fzf --reverse --prompt='wifi > ' )
clear

[[ -n $selection ]] || exit

ssid=$(printf "$selection" | awk '{ print $2 }' )
nmcli --ask device wifi connect "$ssid"