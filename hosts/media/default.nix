{
  core = [ ../../modules/base ];
  hardware = [ ./hardware.nix ];
  user = [ ../../idm/users/media ];
  desktop = [ ../../modules/desktops/gnome-kiosk ];
  profiles = [ ];
  services = [ ];
  testing = [ ./vm.nix ];
}
