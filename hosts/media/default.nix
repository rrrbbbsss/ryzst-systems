{ config, pkgs, ... }:
{
  imports = [
    ../../modules/base
    ../../idm/users/media
    ../../modules/desktops/gnome-kiosk
  ];
}