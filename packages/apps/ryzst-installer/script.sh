#!/usr/bin/env bash

set -euo pipefail

FLAKE="github:rrrbbbsss/ryzst-systems"
FLAKE_REPO="git@${FLAKE}.git"
REGISTRATION_JSON=/tmp/registration.json
HOST=""
SECRETS_DIR=/mnt/nix/secrets
STATE_DIR=/mnt/nix/state

function Confirmation() {
    printf '%s\n' "$1"
    CONFIRM=$(printf "yes\nno" | fzf --prompt="$1: $2 > " --reverse)
    printf '%s\n\n' "$CONFIRM"
    if [[ $CONFIRM == "" || $CONFIRM == "no" ]]; then
        printf 'Canceled: Run "sudo ryzst-installer" to restart installation\n\n'
        exit 1
    fi
}

function PreChecks() {
    if [[ $EUID -ne 0 ]]; then
        printf 'ERROR: Please run as root\n\n'
        exit 1
    elif ! grep "root=LABEL=ryzst-iso" /proc/cmdline &>/dev/null; then
        printf 'ERROR: Please boot into the installation media first\n\n'
        exit 1
    elif ! ls /sys/firmware/efi &>/dev/null; then
        printf 'ERROR: UEFI not detected.\n\n'
        exit 1
    fi

    Confirmation 'Procced with system installation' ''
}

function SetupNetwork() {
    CONNECTIVITY=$(nmcli -g CONNECTIVITY general status)
    while ls /sys/class/ieee80211/*/device/net &>/dev/null && [[ $CONNECTIVITY != "full" ]]; do
        printf "Connect to wifi:\n"
        fzf-wifi
        printf "\n"
    done
    # validate network connection
    printf "Validating Internet connection:\n"
    if curl --max-time 15 --retry 3 --retry-delay 5 https://cache.nixos.org &>/dev/null; then
        printf "success\n\n"
    else
        printf "ERROR: Cannot connect to Internet\n"
        exit 1
    fi
}

function SelectHost() {
    printf "Select Host:\n"
    HOSTS=$(nix flake show "$FLAKE" --json 2>/dev/null | jq -r '.nixosConfigurations | keys[]')
    HOST=$(printf "%s\n" "${HOSTS[@]}" | fzf --prompt="Select Host to Install: " --reverse)
    printf "%s\n\n" "$HOST"
    if [[ $HOST == "" ]]; then
        printf "ERROR: Invalid selection\n\n"
        exit 1
    fi

    Confirmation 'Confirm host to install' "$HOST"
}

function SetupDisks() {
    printf "Partition/Format/Mount disks:\n"
    nix build --print-out-paths "${FLAKE}#nixosConfigurations.${HOST}.config.system.build.diskoScript"
    printf 'success\n\n'
}

function GenerateInstanceData() {
    printf "Generating Instance data:\n"
    # generate machineid
    (umask 0333 && systemd-machine-id-setup --print >$STATE_DIR/etc/machine-id)
    # get endpoint
    ENDPOINT="todo"
    # generate iid
    IID=$(openssl rand -hex 8 | fold -w 4 | paste -sd ':' -)
    # generate ssh key
    ssh-keygen -q -N "" -C "" -t ed25519 -f $SECRETS_DIR/ssh_host_ed25519_key
    SSHPUB=$(cat $SECRETS_DIR/ssh_host_ed25519_key.pub)
    # generate wireguard keys
    wg genkey |
        (umask 0077 && tee $SECRETS_DIR/wg0_key) |
        (umask 0033 wg pubkey >$SECRETS_DIR/wg0_key.pub)
    WGPUB=$(cat $SECRETS_DIR/wg0_key.pug)
    # copy over nm connection
    cp --parents -r /etc/NetworkManager/system-connections/ $STATE_DIR

    jq -n \
        --arg endpoint "$ENDPOINT" \
        --arg iid "$IID" \
        --arg ssh-pub "$SSHPUB" \
        --arg wg-pub "$WGPUB" \
        '$ARGS.named' >$REGISTRATION_JSON
    printf 'success\n\n'
}

function RegisterInstanceData() {
    printf "Registering Instance data:\n"
    while ! gpg --card-status &>/dev/null; do
        fzf --reverse --prompt="Please insert yubikey to register device: > " <<<"proceed"
    done
    GPG_CARD=$(gpg --card-status)
    ADMIN_NAME=$(sed -n -e 's/Name of cardholder: \(.*\)/\1/p' <<<"$GPG_CARD")
    ADMIN_EMAIL=$(sed -n -e 's/Login data.*: \(.*\)/\1/p' <<<"$GPG_CARD")
    ADMIN_KEY=$(gpg --locate-keys --auto-key-locate clear,wkd --with-colons "$ADMIN_EMAIL" |
        awk -F: '$1 == "fpr" {print $10;exit}')
    LOCAL_REPO=/tmp/repo
    rm -rf "$LOCAL_REPO"
    git clone --depth 1 "$FLAKE_REPO" "$LOCAL_REPO"
    cp $REGISTRATION_JSON $LOCAL_REPO/hosts/"$HOST"
    git -C $LOCAL_REPO config user.name "$ADMIN_NAME"
    git -C $LOCAL_REPO config user.email "$ADMIN_EMAIL"
    git -C $LOCAL_REPO config user.signingKey "$ADMIN_KEY"
    git -C $LOCAL_REPO add /tmp/repo/hosts/"$HOST"/registration.json
    git -C $LOCAL_REPO commit -S -m "registraion: register $HOST"
    git -C $LOCAL_REPO push origin main
    printf 'success\n\n'
}

function InstallHost() {
    printf "Installing system:\n"
    nixos-install --flake "${FLAKE}#${HOST}" --root /mnt --no-root-password
}

function Finish() {
    sync
    umount -R /mnt
    zpool export -a
    swapoff --all
    Confirmation 'Reboot to finish installation' ''
    reboot
}

##################
###installation###
##################
PreChecks
SetupNetwork
SelectHost
SetupDisks
GenerateInstanceData
InstallHost
#RegisterInstanceData
Finish
