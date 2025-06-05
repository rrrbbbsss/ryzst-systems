{ config, pkgs, ... }:
let
  inherit (config.device) user;
  group = "lirc";
in
{
  users.groups.${group} = { };
  users.users.${user}.extraGroups = [ group ];
  services.udev.extraRules = ''
    KERNEL=="lirc[0-9]*", SUBSYSTEM=="lirc", \
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="04d8", ATTRS{idProduct}=="fd08", \
    GROUP="${group}", MODE="0660"
  '';
}
