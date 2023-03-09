{ nixpkgs, pkgs, system, home-manager }:
let
  mkMachine = { name, test, core, hardware, user, desktop, profiles, services, testing }:
    nixpkgs.lib.nixosSystem {
      inherit system pkgs;
      modules = [
        { networking.hostName = "${name}"; }
        home-manager.nixosModule
        ../modules/default.nix
      ]
      ++ core ++ user ++ desktop ++ profiles ++ services ++ (
        if test
        then
          testing ++ [ (nixpkgs + "/nixos/modules/virtualisation/qemu-vm.nix") ]
        else
          hardware
      );
    };

  mkMachines = { dir, test }: with builtins;
    mapAttrs
      (name: value:
        mkMachine ((import (dir + "/${name}")) // { inherit name test; }))
      (readDir dir);

  mkHosts = dir: mkMachines { inherit dir; test = false; };
  mkVMs = dir: mkMachines { inherit dir; test = true; };

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
    inherit mkTemplates;
  };
in
lib
