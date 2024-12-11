{ config, pkgs, ... }:
{
  imports = [
    ../../idm/users/man
    ../../modules/profiles/libvirtd.nix
  ];

  system.stateVersion = "22.11";
}
