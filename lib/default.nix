{ self, ... }:
let
  lib-nixpkgs = self.inputs.nixpkgs.lib;
  getDirs = dir: with lib-nixpkgs.attrsets;
    foldlAttrs
      (acc: n: v:
        if v == "directory" then { ${n} = dir + "/${n}"; } // acc else acc)
      { }
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
          os = {
            hostname = name;
            locale = "en_US.UTF-8";
            timezone = "America/Chicago";
            domain = "mek.ryzst.net";
            flake = "github:rrrbbbsss/ryzst-systems";
          };
          nix.registry = {
            ryzst-systems.flake = self;
          } // (builtins.mapAttrs (n: v: { flake = self.inputs.${n}; }) self.inputs);
          nixpkgs.overlays = [ self.outputs.overlays.default ];
        }
        self.inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            sharedModules = [ self.outputs.homeManagerModules.default ];
          };
        }
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


  mkChecks = { system }: with lib-nixpkgs;
    (concatMapAttrs (n: v: { "packages-${n}" = v; }) self.packages.${system}) //
    (concatMapAttrs (n: v: { "devShells-${n}" = v; }) self.devShells.${system});

  lib = {
    inherit getDirs;
    inherit mkHosts;
    inherit mkVMs;
    inherit mkISOs;
    inherit mkChecks;
  };
in
lib
