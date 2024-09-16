#!/usr/bin/env bash

set -euo pipefail

flake="git+ssh://git@git.int.ryzst.net/domain"

# run as sudo
if [[ $EUID -ne 0 ]]; then
  printf "ERROR: Please run as root\n\n"
  exit 1
fi

# check for usb drives
USBSTORAGE=$(lsblk -A -o TRAN,PATH,VENDOR,SIZE | awk '$1 == "usb" {print $2, $3, $4}')
if [[ $USBSTORAGE == "" ]]; then
  printf "ERROR: No usb storage devices plugged in\n\n"
  exit 1
fi

# select usb drive
SELECTION=$(fzf --prompt="Select USB Device to format: " --reverse <<<"$USBSTORAGE")
printf "\nSelect USB Device to format:\n"
printf '%s\n\n' "$SELECTION"
if [[ $SELECTION == "" ]]; then
  printf "Invalid selection\n\n"
  exit 1
fi

# confirm correct usb drive
printf 'Confirm to write to: %s\n' "$SELECTION"
CONFIRM=$(printf "yes\nno" | fzf --prompt="Confirm to write to: $SELECTION > " --reverse)
printf '%s\n\n' "$CONFIRM"
if [[ $CONFIRM == "" || $CONFIRM == "no" ]]; then
  printf "Canceled\n\n"
  exit 1
fi
SELECTION=$(echo "$SELECTION" | awk '{ print $1 }')

# dd iso to drive
printf 'Burning ISO to %s:\n' "$SELECTION"
dd if="$(nix build "$flake#iso-installer" --print-out-paths)"/iso/installer.iso \
  of="$SELECTION" bs=4M conv=fsync oflag=direct status=progress
