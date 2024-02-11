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

  names = import ./names { inherit self; };

  types = {
    username = lib-nixpkgs.types.mkOptionType {
      name = "username";
      description = "byteword username";
      inherit (names.user) check;
    };

    hostname = lib-nixpkgs.types.mkOptionType {
      name = "hostname";
      description = "byteword hostname";
      inherit (names.host) check;
    };
  };
in
{
  inherit getDirs;
  inherit getFilesList;
  inherit names;
  inherit types;
}
