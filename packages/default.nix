{ self, system, lib, pkgs, ryzst, ... }:
let
  mkPackages = dir:
    pkgs.lib.foldlAttrs
      (acc: name: path:
        acc // (import path { inherit self system lib pkgs ryzst; })
      )
      { }
      (self.lib.getDirs dir);
in
mkPackages ./.
