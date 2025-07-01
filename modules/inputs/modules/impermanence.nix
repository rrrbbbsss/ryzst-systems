{ self, ... }:
{
  imports = [
    self.inputs.impermanence.nixosModules.impermanence or
      self.inputs.ryzst.inputs.impermanence.nixosModules.impermanence
  ];

  home-manager.sharedModules = [
    self.inputs.impermanence.nixosModules.home-manager.impermanence or
      self.inputs.ryzst.inputs.impermanence.nixosModules.home-manager.impermanence
  ];
}
