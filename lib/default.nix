{ self, ... }:
let
  lib-nixpkgs = self.inputs.nixpkgs.lib;
  getDirs = dir: with lib-nixpkgs.attrsets;
    foldlAttrs
      (acc: n: v:
        if v == "directory" then { ${n} = dir + "/${n}"; } // acc else acc)
      { }
      (builtins.readDir dir);
  getFilesList = dir: with lib-nixpkgs.attrsets;
    foldlAttrs
      (acc: n: v:
        if v == "regular" then [ (dir + "/${n}") ] ++ acc else acc)
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
        (import ../modules { inherit self; })
        { os.hostname = name; }
        (path + "/default.nix")
      ] ++ hardwares.${target};
    };

  mkSystems = { dir, target }: with builtins;
    mapAttrs
      (name: value:
        mkSystem { inherit name target; path = dir + "/${name}"; })
      (getDirs dir);

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

  mkChecks = { system }: with lib-nixpkgs;
    (concatMapAttrs (n: v: { "packages-${n}" = v; }) self.packages.${system}) //
    (concatMapAttrs (n: v: { "devShells-${n}" = v; }) self.devShells.${system});
  hostnames = import ./names { inherit self; };

  lib = {
    inherit getDirs;
    inherit getFilesList;
    inherit mkHosts;
    inherit mkVMs;
    inherit mkChecks;
    inherit hostnames;
  };
in
lib
