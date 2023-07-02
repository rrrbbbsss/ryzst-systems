#!/usr/bin/env bash

set -eo pipefail

# check for usb drives
USBSTORAGE=$(lsblk -A -o TRAN,PATH,VENDOR,SIZE | awk '$1 == "usb" {print $2, $3, $4}')
if [[ $USBSTORAGE = "" ]]; then
    printf "ERROR: No usb storage devices plugged in\n\n"
    exit 1
fi

# select usb drive
SELECTION=$(echo $USBSTORAGE | fzf --prompt="Select USB Device to format: " --reverse)
printf "\nSelect USB Device to format:\n"
printf "$SELECTION\n\n"
SELECTION=$(echo $SELECTION | awk '{ print $1 }')
if [[ $SELECTION = "" ]]; then
    printf "Invalid selection\n\n"
    exit 1
fi

# confirm correct usb drive
printf "Confirm to write to: $SELECTION\n"
CONFIRM=$(printf "yes\nno" | fzf --prompt="Confirm to write to: $SELECTION > " --reverse)
printf "$CONFIRM\n\n"
if [[ $CONFIRM = "" || $CONFIRM = "no" ]]; then
    printf "Canceled\n\n"
    exit 1
fi

# dd iso to drive
RESULT=$(nix build ".#iso-$1" --print-out-paths) &&
printf "\ndd if=$RESULT/iso/$1.iso of=$SELECTION\n" &&
sudo dd if=$RESULT/iso/$1.iso of=$SELECTION bs=4M conv=fsync status=progress