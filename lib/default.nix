self:
let
  inherit (self.inputs) nixpkgs;

  mkSystems = self: f:
    nixpkgs.lib.listToAttrs
      (map
        (spec:
          let
            string = spec.local +
              (if spec.cross == null then "" else "/${spec.cross}");
            attr = {
              inherit string;
              inherit (spec) local cross;
              native = spec.native or false;
            };
          in
          nixpkgs.lib.nameValuePair string (f attr))
        self.systems);

  mkInstances = self: config:
    # https://wiki.nixos.org/wiki/Cross_Compiling#Leveraging_the_binary_cache
    mkSystems self (system:
      let
        native-overlay =
          if builtins.isFunction system.native
          then [
            # maybe use a vanilla nixpkgs instead...
            (final: prev: system.native
              self.instances.${system.cross})
          ]
          else [ ];
      in
      import nixpkgs {
        inherit config;
        overlays = native-overlay ++ [ self.overlays.default ];
        localSystem = system.local;
        crossSystem = system.cross;
      });

  mkPackages = dir: pkgs: system:
    # TODO: get rid of "system"
    nixpkgs.lib.foldlAttrs
      (acc: name: path:
        acc // (import path {
          inherit self pkgs;
          system = system.string;
        })
      )
      { }
      (getDirs dir);


  getDirs = dir: with nixpkgs.lib.attrsets;
    foldlAttrs
      (acc: n: v:
        if v == "directory" then { ${n} = dir + "/${n}"; } // acc else acc)
      { }
      (builtins.readDir dir);

  getFilesList = dir: with nixpkgs.lib.attrsets;
    foldlAttrs
      (acc: n: v:
        if v == "regular" then [ (dir + "/${n}") ] ++ acc else acc)
      [ ]
      (builtins.readDir dir);

  names = import ./names { inherit self; };

  types = {
    username = nixpkgs.lib.types.mkOptionType {
      name = "username";
      description = "byteword username";
      inherit (names.user) check;
    };

    hostname = nixpkgs.lib.types.mkOptionType {
      name = "hostname";
      description = "byteword hostname";
      inherit (names.host) check;
    };
  };
in
{
  inherit mkSystems;
  inherit mkInstances;
  inherit mkPackages;
  inherit getDirs;
  inherit getFilesList;
  inherit names;
  inherit types;
}
