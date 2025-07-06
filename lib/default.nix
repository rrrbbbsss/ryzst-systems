self:
let
  inherit (self.inputs) nixpkgs;
  inherit (import ./base self) getDirs;

  mkLib = dir:
    nixpkgs.lib.foldlAttrs
      (acc: name: path:
        acc // (import path self))
      { }
      (getDirs dir);
in
mkLib ./.
