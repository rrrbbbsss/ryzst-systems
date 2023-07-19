#!/usr/bin/env bash

set -eo pipefail

REPO="github:rrrbbbsss/ryzst-systems"
REPO_URL="https://github.com/rrrbbbsss/ryzst-systems"

#checks
if ! cat /proc/cmdline | grep " root=LABEL=ryzst-iso " &>/dev/null; then
    printf "ERROR: Please boot into the installation media first\n\n"
    exit 1
fi
if ! ls /sys/firmware/efi &>/dev/null; then
    printf "ERROR: UEFI not detected.\n"
    exit 1
fi

# confirm installation
printf "Proceed with system installation:\n"
CONFIRM=$(printf "yes\nno" | fzf --prompt="Proceed with system installation: $SELECTION > " --reverse)
printf "$CONFIRM\n\n"
if [[ $CONFIRM = "" || $CONFIRM = "no" ]]; then
    printf "Canceled. Run \"sudo ryzst system intall\" to restart installation\n\n"
    exit 1
fi

# setup wifi
if ls /sys/class/ieee80211/*/device/net &>/dev/null; then
    printf "Connect to wifi:\n"
    fzf-wifi
    printf "\n"
fi

# validate network connection
printf "Validating Internet connection...\n"
if curl --max-time 15 --retry 3 --retry-delay 5 https://cache.nixos.org &>/dev/null; then
    printf "success\n\n"
else   
    printf "ERROR: Cannot connect to Internet\n"
    exit 1
fi

# select host
printf "Select Host:\n"
rm -rf /tmp/ryzst
git clone --depth 1 $REPO_URL /tmp/ryzst &>/dev/null
HOSTS=$(ls /tmp/ryzst/hosts)
HOST=$(printf "%s\n" "${HOSTS[@]}" | fzf --prompt="Select Host to Install: " --reverse)
printf "$HOST\n\n"
if [[ $HOST = "" ]]; then
    printf "ERROR: Invalid selection\n\n"
    exit 1
fi
CONFIRM=$(printf "yes\nno" | fzf --prompt="Confirm host to install: $HOST > " --reverse)
if [[ $CONFIRM = "" || $CONFIRM = "no" ]]; then
    printf "Canceled\n\n"
    exit 1
fi

# disko (zap_create_mount)
$(nix build --print-out-paths $REPO\#nixosConfigurations.$HOST.config.system.build.diskoScript)

# generate keys
PERSIST=/mnt/persist
SECRETS=$PERSIST/secrets
mkdir -p $PERSIST $SECRETS
# generate wireguard keys
wg genkey | (umask 0037 && tee $SECRETS/wg0_key) | wg pubkey > $SECRETS/wg0_key.pub
# generate ssh key
ssh-keygen -q -N "" -t ed25519 -f $SECRETS/ssh_host_e25519_key
# generate machineid
(umask 0333 && systemd-machine-id-setup --print > $SECRETS/machineid)

# install nixos from flake
printf "Installing system:\n"
nixos-install --flake $REPO\#$HOST --root /mnt --no-root-password
# todo: register device (wg0_key.pub ssh_host_e25519_key.pub)...

# finish
sync
umount -R /mnt
zpool export -a
swapoff --all
CONFIRM=$(printf "reboot" | fzf --prompt="Remove installation media and finish installation: > " --reverse)
printf "$CONFIRM\n\n"
if [[ $CONFIRM = ""  ]]; then
    printf "Canceled\n\n"
    exit 1
fi
reboot
