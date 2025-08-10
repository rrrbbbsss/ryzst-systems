self:
let
  mkHosts = dir: with builtins;
    mapAttrs
      (name: path: {
        module = path;
        hardware = "${path}/hardware.nix";
        # TODO: ip...
      } // fromJSON (readFile "${path}/registration.json"))

      (self.lib.getDirs dir);
in
mkHosts ./.
