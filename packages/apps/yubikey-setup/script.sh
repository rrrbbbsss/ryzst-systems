#!/usr/bin/env bash

set -eo pipefail

# select yubikey
YUBIKEYS=$(ykman list)
if [[ $YUBIKEYS == "" ]]; then
    printf "ERROR: No yubikey plugged in\n\n"
    exit 1
fi
YUBIKEY=$(printf '%s' "$YUBIKEYS" | fzf --prompt="Select USB Device to format: " --reverse)
SERIAL=$(printf '%s' "$YUBIKEY" | sed -n -e 's/^.*Serial: //p')

# enter lock code
#CODE=$(read -rp "Enter Yubikey Lock Code: ")
#ykman -d $SERIAL config set-lock-code --lock-code $CODE
printf "\n"

# enable/disable applications
printf "Enabling/Disabling Yubikey Applications:\n"
ykman -d "$SERIAL" config usb --enable FIDO2 -f && sleep 1
ykman -d "$SERIAL" config usb --disable OTP -f && sleep 1
ykman -d "$SERIAL" config usb --disable U2F -f && sleep 1
ykman -d "$SERIAL" config usb --disable OATH -f && sleep 1
ykman -d "$SERIAL" config usb --disable PIV -f && sleep 1
# todo again: https://github.com/drduh/YubiKey-Guide
ykman -d "$SERIAL" config usb --disable OPENPGP -f && sleep 1
ykman -d "$SERIAL" config usb --disable HSMAUTH -f && sleep 1
ykman -d "$SERIAL" config nfc --disable-all -f && sleep 1
printf "\n"

# fido
printf "Set FIDO2 Access Pin:\n"
ykman fido access change-pin
printf "\n"
ssh-keygen -t ed25519-sk -O resident -O verify-required
pamu2fcfg --origin pam://mek.ryzst.net --pin-verification
# set lock code
#ykman -d $SERIAL config set-lock-code --generate
