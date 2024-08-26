{ self, system, lib, pkgs, ... }:
let
  mkPackages = dir:
    pkgs.lib.foldlAttrs
      (acc: name: path:
        acc // (import path { inherit self system lib pkgs; })
      )
      { }
      (self.lib.getDirs dir);
in
mkPackages ./.
