{ self, ... }:
let
  name = "iso-installer";
  iso = (self.inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit self; };
    modules = [
      "${self.inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
      ./installer.nix
      self.outputs.settingsModules.default
    ];
  }).config.system.build.isoImage;
in
{
  ${name} = iso;
}
