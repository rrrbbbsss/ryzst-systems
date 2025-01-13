#!/usr/bin/env bash

set -euo pipefail

# TODO: redo this whole thing
FLAKE="git+ssh://git@git.int.ryzst.net/domain"
FLAKE_REPO="git@${FLAKE}.git"
REGISTRATION_JSON=/tmp/registration.json
HOST=""
SECRETS_DIR=/mnt/persist/secrets
STATE_DIR=/mnt/persist

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
  LINKS=$(cat /sys/class/net/*/carrier |
    awk '/1/{a++}END{ print (a>1)?"up":"down" }')
  while ls /sys/class/ieee80211/*/device/net &>/dev/null && [[ $LINKS == "down" ]]; do
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

# TODO: remove
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
  # copy over wifi connection TODO: if wireless is used...
  cp --parents -r /var/lib/iwd $STATE_DIR
  # TODO: hardware test
  HARDWARE="todo"
  # TODO: get endpoint
  ENDPOINT="todo"
  # TODO: ip from preallocated hostname
  IP="todo"
  VERSION="$(nix flake metadata --json | jq -r '.locks.nodes.nixpkgs.original.ref' | cut -f2 -d '-')"

  # TODO: use gokey...
  # "secrets"
  # generate nix key
  NIX_SECRETS_DIR=$SECRETS_DIR/nix
  mkdir -p $NIX_SECRETS_DIR
  nix-store --generate-binary-cache-key \
    "$HOST.mek.ryzst.net" \
    $NIX_SECRETS_DIR/nix_key \
    $NIX_SECRETS_DIR/nix_key.pub
  NIXPUB=$(cat $NIX_SECRETS_DIR/nix_key.pub)
  # generate ssh key
  SSH_SECRETS_DIR=$SECRETS_DIR/ssh
  mkdir $SSH_SECRETS_DIR
  ssh-keygen -q -N "" -C "" -t ed25519 -f $SSH_SECRETS_DIR/ssh_host_ed25519_key
  SSHPUB=$(cat $SSH_SECRETS_DIR/ssh_host_ed25519_key.pub)
  # generate wireguard keys
  WG_SECRETS_DIR=$SECRETS_DIR/wireguard
  mkdir $WG_SECRETS_DIR
  wg genkey |
    (umask 0077 && tee $WG_SECRETS_DIR/wg0_key) |
    (umask 0033 && wg pubkey >$WG_SECRETS_DIR/wg0_key.pub)
  WGPUB=$(cat $WG_SECRETS_DIR/wg0_key.pub)
  # generate syncthing keys
  SYNCTHING_SECRETS_DIR=$SECRETS_DIR/syncthing
  mkdir $SYNCTHING_SECRETS_DIR
  syncthing --generate=$SYNCTHING_SECRETS_DIR
  SYNCTHING_ID=$(syncthing --home=$SYNCTHING_SECRETS_DIR --device-id)

  jq -n \
    --arg ip "$IP" \
    --arg endpoint "$ENDPOINT" \
    --arg hardware "$HARDWARE" \
    --arg version "$VERSION" \
    --arg nix "$NIXPUB" \
    --arg ssh "$SSHPUB" \
    --arg wireguard "$WGPUB" \
    --arg syncthing "$SYNCTHING_ID" \
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
