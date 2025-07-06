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

  # this should be fine if an overlay only needs to add surface stuff,
  # but if a 3rd party overlay needs to tweak deep pkgs,
  # then might need to use new instance of nixpkgs...
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

in
{
  inherit
    mkSystems
    mkInstances
    mkBoxed
    getDirs
    getFilesNoSuffix
    getFilesList;
}
