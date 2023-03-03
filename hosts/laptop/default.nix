{
  core = [ ../../modules/base ];
  hardware = [ ./hardware.nix ];
  user = [ ../../idm/users/rrrbbbsss ];
  desktop = [ ../../modules/desktops/sway ];
  profiles = [ ./profile.nix ];
  services = [ ];
  testing = [ ./vm.nix ];
}
