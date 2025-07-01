{ self, ... }:
{
  imports = [
    self.inputs.disko.nixosModules.disko or
      self.inputs.ryzst.inputs.disko.nixosModules.disko
  ];
}
