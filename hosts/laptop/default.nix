{
  core = [ ../../modules/base ];
  hardware = [ ./hardware.nix ];
  user = [ ../../idm/users/rrrbbbsss ];
  desktop = [ ../../modules/desktops/sway ];
  profiles = [ ];
  services = [ ];
  testing = [ ./vm.nix ];
}
