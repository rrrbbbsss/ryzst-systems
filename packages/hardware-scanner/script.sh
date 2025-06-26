# shellcheck shell=bash

# https://wiki.archlinux.org/title/Modalias
# https://pci-ids.ucw.cz/
# http://www.linux-usb.org/usb-ids.html

# so like if
# modalias -> kernel module
# so like then why not
# modalias -> nixos module(?)
# ...(?)...

function resolve_modules() {
  while read -r MODULE; do
    modprobe --resolve-alias "$MODULE" 2>/dev/null || echo ""
  done
}

MODALIASES=$(find /sys/devices -name modalias -print0 \
               | xargs -0 cat \
               | sort -u)
printf 'modaliases:\n%s\n\n' "$MODALIASES"

# https://uefi.org/PNP_ID_List
# https://github.com/linuxhw/EDID
# https://en.wikipedia.org/wiki/Extended_Display_Identification_Data#EDID_1.4_data_format
EDID=$(find /sys/devices -name edid -print0 \
               | xargs -0 -I '{}' xxd -p -s+8 -l 4 '{}')
printf 'edid:\n%s\n\n' "$EDID"

# cpu
CPU="todo"
printf 'cpu:\n%s\n\n' "$CPU"
# board
BOARD=$(grep 'dmi:.*' <<<"$MODALIASES" | cut -d ':' -f 1,2)
printf 'dmi:\n%s\n\n' "$BOARD"
# graphics
GRAPHICS=$(grep 'pci:v.*d.*sv.*sd.*bc03sc.*i.*' <<<"$MODALIASES")
printf 'graphics:\n%s\n\n' "$GRAPHICS"
# wireless (don't have good usb dingle to test/validate)
WIRELESS=$(grep 'pci:v.*d.*sv.*sd.*bc02sc80i.*' <<<"$MODALIASES")
printf 'wireless:\n%s\n\n' "$WIRELESS"
# ethernet (don't have good usb dingle to test/validate)
ETHERNET=$(grep 'pci:v.*d.*sv.*sd.*bc02sc00i.*' <<<"$MODALIASES")
printf 'ethernet:\n%s\n\n' "$ETHERNET"
# storage
#STORAGE=TODO
# tpm
#TPM=todo

#DEVICETREE=$(cat /sys/firmware/devicetree/base/compatible)
#printf 'devicetree: %s' "$DEVICETREE"

MODULES=$(resolve_modules <<<"$MODALIASES" \
            | sort -u)
printf 'modules:\n%s\n\n' "$MODULES"
