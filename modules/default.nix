self:
# TODO: clean this up...
let
  default-imports = [
    #self
    ./hardware
    ./ryzst
    ./os
    ./keys
    #home manager
    self.inputs.home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        sharedModules = [
          self.outputs.homeManagerModules.default
        ];
      };
    }
    # disko
    self.inputs.disko.nixosModules.disko
    # impermanence
    self.inputs.impermanence.nixosModules.impermanence
    {
      home-manager.sharedModules = [
        self.inputs.impermanence.nixosModules.home-manager.impermanence
      ];
    }
    # nix-index
    self.inputs.nix-index-database.nixosModules.nix-index
    { programs.command-not-found.enable = false; }
  ];
in
{
  default = { config, pkgs, ... }:
    {
      imports = default-imports;

      config = {

        programs.nix-index.package = pkgs.nix-index-with-db;

        os = {
          locale = "en_US.UTF-8";
          timezone = "America/Chicago";
          domain = "mek.ryzst.net";
          flake = "git+ssh://git@git.int.ryzst.net/domain";
        };

        nix.registry = {
          ryzst-systems.flake = self;
        } // (builtins.mapAttrs (n: v: { flake = self.inputs.${n}; }) self.inputs);

        nixpkgs.pkgs = self.instances.${config.nixpkgs.hostPlatform.system};
      };
    };
}
