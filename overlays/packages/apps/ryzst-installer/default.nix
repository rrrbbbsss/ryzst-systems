{ writeShellApplication
, fzf
, coreutils-full
, util-linux
, gawk
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
writeShellApplication {
  name = "ryzst-installer";
  runtimeInputs = [
    fzf
    coreutils-full
    util-linux
    gawk
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
  ];
  text = builtins.readFile ./script.sh;
}
