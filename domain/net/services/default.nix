self:
let
  mkServices = dir: with builtins;
    mapAttrs
      (n: v: {
        # it is a start...
        module = v;
      })
      (self.lib.getDirs dir);
in
mkServices ./.
