{ lib
, runCommandLocal
, makeWrapper
, bash
, fzf
, coreutils-full
, util-linux
, gawk
, ryzst
, openssl
, wireguard-tools
, jq
, gnupg
, gnused
, gnugrep
, git
, zfs
, systemd
, nix
, openssh
, networkmanager
, curl
, syncthing
}:

runCommandLocal "ryzst-installer"
{
  script = ./script.sh;
  nativeBuildInputs = [ makeWrapper ];
} ''makeWrapper $script $out/bin/ryzst-installer \
      --prefix PATH : ${lib.makeBinPath [
  bash
  fzf
  coreutils-full
  util-linux
  gawk
  ryzst.fzf-wifi
  openssl
  wireguard-tools
  jq
  gnupg
  gnused
  gnugrep
  git
  zfs
  systemd
  nix
  openssh
  networkmanager
  curl
  syncthing
  ]}''
