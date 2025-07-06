{ self, pkgs, ... }:
let
  name = "iso-installer";
  iso = (self.inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    # TODO: remove self as special arg
    specialArgs = { inherit self; };
    modules = [
      "${self.inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
      ./installer.nix
      self.outputs.settingsModules.default
      { nixpkgs.pkgs = pkgs; }
    ];
  }).config.system.build.isoImage;
in
{
  ${name} = iso;
}
