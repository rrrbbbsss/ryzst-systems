{ config, pkgs, ... }:
let
  inherit (config.device) user;
  inherit (config.home-manager.users.${user}.wayland.windowManager.sway.config) modifier;
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
  home-manager.users.${user}.wayland.windowManager.sway.config.keybindings = {
    "${modifier}+Prior" = ''
      exec ${pkgs.v4l-utils}/bin/ir-ctl -d /dev/lirc0 --send=${./powerbutton}
    '';
  };
}
