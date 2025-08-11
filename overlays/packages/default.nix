self:
let
  inherit (self.inputs) nixpkgs;
  mkPackages = dir: pkgs:
    nixpkgs.lib.foldlAttrs
      (acc: name: path:
        acc // (import path { inherit self pkgs; }))
      { }
      (self.lib.getDirs dir);
in
final: prev:
{ ryzst = mkPackages ./. final; }
