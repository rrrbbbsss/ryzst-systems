self:
# TODO: at some point want to mess around with souffle
let
  inherit (self.inputs.ryzst.inputs) nixpkgs;
  mkChecks = dir:
    nixpkgs.lib.foldlAttrs
      (acc: name: path:
        acc // (import path self))
      { }
      (self.lib.getDirs dir);
in
mkChecks ./.
