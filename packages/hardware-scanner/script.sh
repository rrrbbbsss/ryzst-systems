# shellcheck shell=bash

# https://wiki.archlinux.org/title/Modalias
# https://pci-ids.ucw.cz/
# http://www.linux-usb.org/usb-ids.html

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

# storage
#STORAGE=TODO

MODULES=$(resolve_modules <<<"$MODALIASES" \
            | sort -u)
printf 'modules:\n%s\n\n' "$MODULES"
