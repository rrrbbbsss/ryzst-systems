{ self, config, lib, ... }:
let
  ignoreDirs =
    if builtins.isNull config.device.user
    then [ ]
    else [
      "/home/${config.device.user}/.local/state/nix/profiles/"
      "/home/${config.device.user}/.local/state/home-manager/gcroots/"
    ];
  users =
    if builtins.isNull config.device.user
    then [ ]
    else [ config.device.user ];
  version = config.system.stateVersion;
in
{
  # TODO: unkinkle...
  imports = [
    self.inputs.home-manager.nixosModules.home-manager or
      self.inputs.ryzst.inputs.home-manager.nixosModules.home-manager
  ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # TODO: maybe this goes elsewhere?
    sharedModules = [
      self.homeManagerModules.default or
        self.inputs.ryzst.homeManagerModules.default
    ];
  };

  # TODO: see what happens with rl-2511
  # this goes away if don't use home-manager so keep it here.
  os.misc-gc.ignoreDirs = ignoreDirs;

  # this is required for home-manager-<user>.service
  # it does bother me...
  nix.settings.allowed-users = users;

  home-manager.users = lib.fold
    (x: acc: { ${x} = { home.stateVersion = version; }; } // acc)
    { }
    users;
}
