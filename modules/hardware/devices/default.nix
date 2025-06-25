self:
let
  inherit (self.inputs) nixpkgs;
in
nixpkgs.lib.foldlAttrs
  (acc: n: v: acc // { ${n} = self.lib.getDirs v; })
{ }
  (self.lib.getDirs ./.)
