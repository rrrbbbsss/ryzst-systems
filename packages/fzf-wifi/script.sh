# shellcheck shell=bash

function cleanup() {
  tail -n +5 |
    head -n -1 |
    sed -e "s:\[1;90m>::g" |
    sed -e "s:\[1;30m::g" |
    sed -e "s:\[0m::g" |
    sed -e "s:\*\x1b.*:\*:g" |
    sed -e "s:\x1b::g" |
    sed 's/[ ]*//'
}

function selector() {
  SELECTION=$(printf '%s' "$1" | fzf --prompt="$2 > " --reverse)
  printf '%s' "$SELECTION"
}

#get device
DEVICES=$(iwctl device list | cleanup | awk '{ print $1}')
if [[ $(wc -l <<<"$DEVICES") -gt 1 ]]; then
  DEVICE=$(selector "$DEVICES" "Select Device")
else
  DEVICE="$DEVICES"
fi

#scan
printf 'Scanning...\n'
iwctl station "$DEVICE" scan
sleep 3
clear

#select network
NETWORKS=$(iwctl station "$DEVICE" get-networks | cleanup)
NETWORK=$(selector "$NETWORKS" "Select Network" | awk '{ NF-=2; print }')

#connect
iwctl station "$DEVICE" connect "$NETWORK"
