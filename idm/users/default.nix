self:
let
  mkUsers = dir: with builtins;
    mapAttrs
      (n: v: {
        module = v;
        uid = self.lib.names.user.toUID n;
      } // fromJSON (readFile "${dir}/${n}/registration.json"))
      (self.lib.getDirs dir);
in
mkUsers ./.
