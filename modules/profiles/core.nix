{ config, pkgs, lib, ... }:
{
  imports = [
    ./base.nix
    ../ryzst/int/dns/client.nix
    ../ryzst/int/ntp/client.nix
    ../ryzst/int/wg/client.nix
  ];

  networking = {
    useDHCP = lib.mkDefault true;
    firewall.enable = true;
  };
}
