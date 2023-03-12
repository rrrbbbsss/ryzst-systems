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
          networking.hostName = "${name}";
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

  mkISOs = dir:
    pkgs.lib.concatMapAttrs
      (n: v: {
        "iso-${n}" = v.config.system.build.isoImage;
      })
      (mkSystems {
        inherit dir;
        target = "iso";
      });

  mkTemplates = dir:
    builtins.mapAttrs
      (name: value:
        let
          template = dir + "/${name}";
        in
        { path = template + "/files"; } // import template)
      (builtins.readDir dir);

  mkChecks = {}: with builtins;
    self.packages.${system} //
    self.devShells.${system} //
    (mapAttrs (n: v: self.nixosConfigurations.${n}.config.system.build.toplevel) self.nixosConfigurations);

  lib = {
    inherit mkHosts;
    inherit mkVMs;
    inherit mkISOs;
    inherit mkTemplates;
    inherit mkChecks;
  };
in
lib
