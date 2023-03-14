{ self, pkgs, system, ... }:
let
  mkSystem = { name, path, target }:
    let
      hardwares =
        {
          host = [ (path + "/hardware.nix") ];
          vm = [ (path + "/vm.nix") ];
          iso = [ ];
        };
    in
    self.inputs.nixpkgs.lib.nixosSystem {
      inherit system pkgs;
      modules = [
        {
          networking = {
            hostName = "${name}";
            domain = "mek.ryzst.net";
          };
          nix.registry = {
            ryzst.flake = self;
          } // (builtins.mapAttrs (n: v: { flake = self.inputs.${n}; }) self.inputs);
        }
        self.inputs.home-manager.nixosModule
        (path + "/default.nix")
        ../modules/default.nix
      ] ++ hardwares.${target};
    };

  mkSystems = { dir, target }: with builtins;
    mapAttrs
      (name: value:
        mkSystem { inherit name target; path = dir + "/${name}"; })
      (readDir dir);

  mkHosts = dir: mkSystems { inherit dir; target = "host"; };

  mkVMs = dir:
    pkgs.lib.concatMapAttrs
      (n: v: {
        "vm-${n}" = v.config.system.build.vm;
      })
      (mkSystems {
        inherit dir;
        target = "vm";
      });

  mkISOs = dir: with pkgs.lib;
    concatMapAttrs
      (n: v: {
        "iso-${n}" = v.config.system.build.isoImage;
      })
      (mkSystems {
        inherit dir;
        target = "iso";
      });

  mkTemplates = dir: with builtins;
    mapAttrs
      (name: value:
        let
          template = dir + "/${name}";
        in
        { path = template + "/files"; } // import template)
      (readDir dir);

  mkChecks = {}: with pkgs.lib;
    (concatMapAttrs (n: v: { "packages-${n}" = v; }) self.packages.${system}) //
    (concatMapAttrs (n: v: { "devShells-${n}" = v; }) self.devShells.${system}) //
    (concatMapAttrs (n: v: { "hosts-${n}" = v.config.system.build.toplevel; }) self.nixosConfigurations);

  lib = {
    inherit mkHosts;
    inherit mkVMs;
    inherit mkISOs;
    inherit mkTemplates;
    inherit mkChecks;
  };
in
lib
