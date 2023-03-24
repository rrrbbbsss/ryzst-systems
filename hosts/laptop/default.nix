{ config, pkgs, ... }:
{
  imports = [
    ../../modules/profiles/base.nix
    ../../modules/profiles/core.nix
    ../../modules/profiles/sway.nix
    ../../idm/users/rrrbbbsss
    ../../modules/ryzst/int/wg/client.nix
  ];
}






