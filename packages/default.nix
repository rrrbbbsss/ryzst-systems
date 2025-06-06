{ self }:
#{ self, system, lib, pkgs, ... }:
let
  inherit (self) instances systems lib;
  inherit (self.inputs) nixpkgs;
in
nixpkgs.lib.genAttrs systems (system:
let
  pkgs = instances.${system};
  mkPackages = dir:
    pkgs.lib.foldlAttrs
      (acc: name: path:
        acc // (import path { inherit self system lib pkgs; })
      )
      { }
      (self.lib.getDirs dir);
in
mkPackages ./.)
