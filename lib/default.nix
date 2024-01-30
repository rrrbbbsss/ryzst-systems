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
        self.outputs.nixosModules.default
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

  hostnames = import ./names { inherit self; };

  lib = {
    inherit getDirs;
    inherit getFilesList;
    inherit mkHosts;
    inherit hostnames;
  };
in
lib
