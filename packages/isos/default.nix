{ system, self, ... }:
let
  name = "iso-installer";
  iso = self.inputs.nixos-generators.nixosGenerate {
    inherit system;
    format = "install-iso";
    modules = [
      ./installer.nix
      (import ../../modules/default.nix { inherit self; })
    ];
  };
in
{
  "${name}" = iso;
}
