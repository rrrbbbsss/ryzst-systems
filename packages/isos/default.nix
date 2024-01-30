{ system, self, ... }:
let
  name = "iso-installer";
  iso = self.inputs.nixos-generators.nixosGenerate {
    inherit system;
    format = "install-iso";
    modules = [
      ./installer.nix
      self.outputs.nixosModules.default
    ];
  };
in
{
  "${name}" = iso;
}
