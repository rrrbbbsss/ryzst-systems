{ system, self, ... }:
let
  name = "iso-installer";
  iso = self.inputs.nixos-generators.nixosGenerate {
    inherit system;
    format = "install-iso";
    specialArgs = { inherit self; };
    modules = [
      ./installer.nix
      self.outputs.nixosModules.default
    ];
  };
in
{
  "${name}" = iso;
}
