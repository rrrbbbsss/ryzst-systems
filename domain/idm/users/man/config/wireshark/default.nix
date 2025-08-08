{ config, pkgs, ... }:
let
  username = config.device.user;
in
{
  users.users.${username}.extraGroups = [ "wireshark" ];

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };
}
