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

  hostnames = import ./names { inherit self; };
in
{
  inherit getDirs;
  inherit getFilesList;
  inherit hostnames;
}
