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

  mkBoxed = prev: overlays:
    let
      f = final: prev;
      g = nixpkgs.lib.extends
        (nixpkgs.lib.composeManyExtensions overlays)
        f;
    in
    nixpkgs.lib.fix g;

  getDirs = dir: with nixpkgs.lib.attrsets;
    foldlAttrs
      (acc: n: v:
        if v == "directory" then { ${n} = dir + "/${n}"; } // acc else acc)
      { }
      (builtins.readDir dir);

  getFilesNoSuffix = dir: with nixpkgs.lib.attrsets;
    foldlAttrs
      (acc: n: v:
        if v == "regular" then {
          ${nixpkgs.lib.removeSuffix ".nix" n} = dir + "/${n}";
        } // acc else acc)
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

  logic = import ./logic self;
in
{
  inherit mkSystems;
  inherit mkInstances;
  inherit mkBoxed;
  inherit getDirs;
  inherit getFilesNoSuffix;
  inherit getFilesList;
  inherit names;
  inherit types;
  inherit logic;
}
