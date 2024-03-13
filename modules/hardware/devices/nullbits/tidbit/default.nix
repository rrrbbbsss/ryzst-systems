{ config, pkgs, lib, ... }:
let
  inherit (config.device) user;
  group = "qmk-flash";
in
{
  config = lib.mkIf user {
    users.groups.${group} = { };
    users.users.${user}.extraGroups = [ group ];
    hardware.keyboard.qmk.enable = true;
    services.udev.packages = [ pkgs.qmk-udev-rules ];
  };
}
