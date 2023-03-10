{ nixpkgs, pkgs, system, home-manager, ... }:
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
    nixpkgs.lib.nixosSystem {
      inherit system pkgs;
      modules = [
        { networking.hostName = "${name}"; }
        home-manager.nixosModule
        (path + "/default.nix")
        ../modules/default.nix
      ] ++ hardwares.${target};
    };

  mkSystems = { dir, target }: with builtins;
    mapAttrs
      (name: value:
        mkSystem { inherit name target; path = dir + "/${name}";})
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

  lib = {
    inherit mkHosts;
    inherit mkVMs;
    inherit mkISOs;
    inherit mkTemplates;
  };
in
lib
