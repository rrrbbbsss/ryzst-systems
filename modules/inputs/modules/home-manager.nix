{ self, config, ... }:
let
  ignoreDirs =
    if builtins.isNull config.device.user
    then [ ]
    else [
      "/home/${config.device.user}/.local/state/nix/profiles/"
      "/home/${config.device.user}/.local/state/home-manager/gcroots/"
    ];
in
{
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

  # this goes away if don't use home-manager so keep it here.
  os.misc-gc.ignoreDirs = ignoreDirs;
}
