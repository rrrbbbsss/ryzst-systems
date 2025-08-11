# shellcheck shell=bash

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

###############
### yubikey ###
###############
# enable applications
printf "Enabling/Disabling Yubikey Applications:\n"
ykman -d "$SERIAL" config usb --enable FIDO2 -f && sleep 1
ykman -d "$SERIAL" config usb --enable PIV -f && sleep 1
# disable applications
ykman -d "$SERIAL" config usb --disable OPENPGP -f && sleep 1
ykman -d "$SERIAL" config usb --disable OTP -f && sleep 1
ykman -d "$SERIAL" config usb --disable U2F -f && sleep 1
ykman -d "$SERIAL" config usb --disable OATH -f && sleep 1
ykman -d "$SERIAL" config usb --disable HSMAUTH -f && sleep 1
ykman -d "$SERIAL" config nfc --disable-all -f && sleep 1
# lock
#CODE=$(read -rp "Enter Yubikey Lock Code: ")
#ykman -d $SERIAL config set-lock-code --lock-code $CODE
#ykman -d $SERIAL config set-lock-code --generate
printf "\n"

############
### fido ###
############
ykman --device "$SERIAL" \
  fido reset --force
printf "Set FIDO2 Access Pin:\n"
ykman --device "$SERIAL" \
  fido access change-pin
#pamu2fcfg --origin pam://mek.ryzst.net --pin-verification
##ssh-keygen -t ed25519-sk -O resident -O verify-required
#printf "\n"

###########
### piv ###
###########
PIV_DEFAULT_PIN="123456"
PIV_DEFAULT_PUK="12345678"
PIV_DEFAULT_MGT="010203040506070801020304050607080102030405060708"
PIV_MGT_ALGO="AES256"
RETRIES="8"
PIV_ALGO="RSA2048"
PIV_HASH="SHA256"
PIV_EXPIRE="3650"
PIV_SUBJECT="CN=man"
#PIN   = DEFAULT| NEVER | ONCE | ALWAYS | MATCH_ONCE | MATCH-ALWAYS
#Touch = DEFAULT| NEVER | ALWAYS | CACHED
PIV_AUTH_PIN="DEFAULT"
PIV_AUTH_TOUCH="DEFAULT"
PIV_SIGN_PIN="DEFAULT"
PIV_SIGN_TOUCH="DEFAULT"
PIV_ENCR_PIN="DEFAULT"
PIV_ENCR_TOUCH="DEFAULT"

ykman --device "$SERIAL" \
  piv reset --force
ykman --device "$SERIAL" \
  piv access change-management-key \
  --force \
  --pin "$PIV_DEFAULT_PIN" \
  --management-key "$PIV_DEFAULT_MGT" \
  --generate \
  --algorithm "$PIV_MGT_ALGO" \
  --protect
# (9a) auth key and cert
ykman --device "$SERIAL" \
  piv keys generate \
  --pin "$PIV_DEFAULT_PIN" \
  --algorithm "$PIV_ALGO" \
  --format PEM \
  --pin-policy "$PIV_AUTH_PIN" \
  --touch-policy "$PIV_AUTH_TOUCH" \
  9a piv-auth.pub
ykman --device "$SERIAL" \
  piv certificates generate \
  --pin "$PIV_DEFAULT_PIN" \
  --subject "$PIV_SUBJECT" \
  --valid-days "$PIV_EXPIRE" \
  --hash-algorithm "$PIV_HASH" \
  9a piv-auth.pub
# (9c) signing key and cert
ykman --device "$SERIAL" \
  piv keys generate \
  --pin "$PIV_DEFAULT_PIN" \
  --algorithm "$PIV_ALGO" \
  --format PEM \
  --pin-policy "$PIV_SIGN_PIN" \
  --touch-policy "$PIV_SIGN_TOUCH" \
  9c piv-sign.pub
ykman --device "$SERIAL" \
  piv certificates generate \
  --pin "$PIV_DEFAULT_PIN" \
  --subject "$PIV_SUBJECT" \
  --valid-days "$PIV_EXPIRE" \
  --hash-algorithm "$PIV_HASH" \
  9c piv-sign.pub
# (9d) encryption key and cert
ykman --device "$SERIAL" \
  piv keys generate \
  --pin "$PIV_DEFAULT_PIN" \
  --algorithm "$PIV_ALGO" \
  --format PEM \
  --pin-policy "$PIV_ENCR_PIN" \
  --touch-policy "$PIV_ENCR_TOUCH" \
  9d piv-encr.pub
ykman --device "$SERIAL" \
  piv certificates generate \
  --pin "$PIV_DEFAULT_PIN" \
  --subject "$PIV_SUBJECT" \
  --valid-days "$PIV_EXPIRE" \
  --hash-algorithm "$PIV_HASH" \
  9d piv-encr.pub
# enable touch for management
ykman --device "$SERIAL" \
  piv access change-management-key \
  --force \
  --pin "$PIV_DEFAULT_PIN" \
  --generate \
  --algorithm "$PIV_MGT_ALGO" \
  --protect \
  --touch
# set pin retries
ykman --device "$SERIAL" \
  piv access set-retries \
  --force \
  --pin "$PIV_DEFAULT_PIN" \
  "$RETRIES" "$RETRIES"
# set pins
ykman --device "$SERIAL" \
  piv access change-pin --pin "$PIV_DEFAULT_PIN"
ykman --device "$SERIAL" \
  piv access change-puk --puk "$PIV_DEFAULT_PUK"
# dump certs
ykman --device "$SERIAL" \
  piv certificates export \
  --format PEM \
  9a piv-auth.crt
ykman --device "$SERIAL" \
  piv certificates export \
  --format PEM \
  9c piv-sign.crt
ykman --device "$SERIAL" \
  piv certificates export \
  --format PEM \
  9d piv-encr.crt

###########
### gpg ###
###########
gpgsm --learn
# generate keys from piv
#gpg --quick-generate-key "$NAME - $KEYID <$EMAIL>" card
#gpg --quick-generate-key "test - 1 <test@test.com>" card
# dump
#gpg --armor --output man.gpg --export "test - 1"
# think about revocation certs...
