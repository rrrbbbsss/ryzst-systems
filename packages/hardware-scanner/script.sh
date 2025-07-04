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

MODULES=$(resolve_modules <<<"$MODALIASES" \
            | sort -u)
printf 'modules:\n%s\n\n' "$MODULES"

# NOTE: was wanting to generate the info for conditional imports,
# but think generating an initial hardware file
# that imports nixos modules based off modalias regex's
# (also edid/devicetree too)
# that can be micromanaged by hand when needed afterwards
# will be the easiest for my home-lab usage.
# (home-lab is too pet'y).

# TODO: use hardware catalag to grep for nixos module matches
# TODO: need to figure out initialramdisk stuff
#       (ie: initrd.availableKernelModules)
#       (peek at script in nixpkgs for nixos)
# TODO: figure out how to handle disk stuff
# TODO: generate hardware.nix
