{ system, self, ... }:
let
  name = "iso-installer";
  iso = self.inputs.nixos-generators.nixosGenerate {
    inherit system;
    format = "install-iso";
    modules = [
      ./installer.nix
      { os.hostname = name; }
      self.outputs.nixosModules.default
    ];
  };
in
{
  "${name}" = iso;
}
