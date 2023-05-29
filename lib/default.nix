{ self, ... }:
let
  lib-nixpkgs = self.inputs.nixpkgs.lib;
  getDirs = dir: with lib-nixpkgs.attrsets;
    foldlAttrs
      (acc: n: v:
        if v == "directory" then [ "./${n}" ] ++ acc else acc)
      [ ]
      (builtins.readDir dir);
  mkSystem = { name, path, target }:
    let
      hardwares =
        {
          host = [ (path + "/hardware.nix") ];
          vm = [ (path + "/vm.nix") ];
          iso = [ ];
        };
    in
    lib-nixpkgs.nixosSystem {
      modules = [
        {
          networking = {
            hostName = "${name}";
          };
          nix.registry = {
            ryzst.flake = self;
          } // (builtins.mapAttrs (n: v: { flake = self.inputs.${n}; }) self.inputs);
          nixpkgs.overlays = [ self.outputs.overlays.default self.inputs.nix-vscode-extensions.overlays.default ];
        }
        self.inputs.home-manager.nixosModules.home-manager
        self.inputs.disko.nixosModules.disko
        self.inputs.impermanence.nixosModules.impermanence
        self.inputs.nix-index-database.nixosModules.nix-index
        { programs.command-not-found.enable = false; }
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
    lib-nixpkgs.concatMapAttrs
      (n: v: {
        "vm-${n}" = v.config.system.build.vm;
      })
      (mkSystems {
        inherit dir;
        target = "vm";
      });

  mkISOs = dir: with lib-nixpkgs;
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

  mkChecks = { system }: with lib-nixpkgs;
    (concatMapAttrs (n: v: { "packages-${n}" = v; }) self.packages.${system}) //
    (concatMapAttrs (n: v: { "devShells-${n}" = v; }) self.devShells.${system});

  lib = {
    inherit getDirs;
    inherit mkHosts;
    inherit mkVMs;
    inherit mkISOs;
    inherit mkTemplates;
    inherit mkChecks;
  };
in
lib
