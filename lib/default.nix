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
  mkVMs = dir: mkSystems { inherit dir; target = "vm"; };
  mkISOs = dir: mkSystems { inherit dir; target = "iso"; };

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
    (mapAttrs (n: v: self.nixosConfiguration.${n}.config.system.build.toplevel ) self.nixosConfigurations) //
    (mapAttrs (n: v: self.vms.${n}.config.system.build.vm ) self.vms) //
    (mapAttrs (n: v: self.isos.${n}.config.system.build.isoImage ) self.isos);

  lib = {
    inherit mkHosts;
    inherit mkVMs;
    inherit mkISOs;
    inherit mkTemplates;
    inherit mkChecks;
  };
in
lib
