#!/usr/bin/env bash
# TODO: this file is just notes right now.
# TODO: clean it up and make it proper.

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
ykman -d "$SERIAL" config usb --enable PIV -f && sleep 1
ykman -d "$SERIAL" config usb --disable OTP -f && sleep 1
ykman -d "$SERIAL" config usb --disable U2F -f && sleep 1
ykman -d "$SERIAL" config usb --disable OATH -f && sleep 1
# TODO: https://github.com/drduh/YubiKey-Guide
ykman -d "$SERIAL" config usb --disable OPENPGP -f && sleep 1
ykman -d "$SERIAL" config usb --disable HSMAUTH -f && sleep 1
ykman -d "$SERIAL" config nfc --disable-all -f && sleep 1
printf "\n"

# piv
# doesn't play ball with gpg at same time...
PIV_PIN="123456"
PIV_PUK="12345678"
PIV_MGT="010203040506070801020304050607080102030405060708"
ykman piv reset --force
ykman piv access set-retries \
  --force \
  --pin "$PIV_PIN" \
  --management-key "$PIV_MGT" \
  8 8
ykman piv keys generate \
  --pin "$PIV_PIN" \
  --management-key "$PIV_MGT" \
  --algorithm ECCP256 \
  --format PEM \
  --pin-policy "DEFAULT" \
  --touch-policy "DEFAULT" \
  9a pubkey.pem
ykman piv certificates generate \
  --pin "$PIV_PIN" \
  --management-key "$PIV_MGT" \
  --subject "CN=man" \
  --valid-days 3650 \
  --hash-algorithm SHA256 \
  9a pubkey.pem
ykman piv access change-management-key \
  --force \
  --pin "$PIV_PIN" \
  --management-key "$PIV_MGT" \
  --generate \
  --algorithm AES256 \
  --protect \
  --touch
ykman piv access change-pin --pin "$PIV_PIN"
ykman piv access change-puk --puk "$PIV_PUK"
ykman piv certificates export \
  --format PEM \
  9a yubicert.pem

# fido
printf "Set FIDO2 Access Pin:\n"
ykman fido access change-pin
printf "\n"
ssh-keygen -t ed25519-sk -O resident -O verify-required
pamu2fcfg --origin pam://mek.ryzst.net --pin-verification
# set lock code
#ykman -d $SERIAL config set-lock-code --generate
