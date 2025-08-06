self:
let
  mkGroups = dir: with builtins;
    mapAttrs
      (n: v: {
        module = v;
        # TODO: gid eventually...
        # it is a start...
      })
      (self.lib.getDirs dir);
in
mkGroups ./.
