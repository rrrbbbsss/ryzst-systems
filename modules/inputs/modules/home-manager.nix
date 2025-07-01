{ self, ... }:
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
}
