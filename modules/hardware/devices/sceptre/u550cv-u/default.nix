{ config, pkgs, ... }:
let
  inherit (config.device) user;
  inherit (config.home-manager.users.${user}.wayland.windowManager.sway.config) modifier;
in
{
  device.ir.code.tv = {
    power = ./power.ir;
  };

  # this should go elsewhere at some point.
  home-manager.users.${user}.wayland.windowManager.sway.config.keybindings = {
    "${modifier}+Prior" = ''
      exec ${pkgs.v4l-utils}/bin/ir-ctl -d /dev/lirc0 --send=${./power.ir}
    '';
  };
}
