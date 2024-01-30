{ self, ... }:
let
  mkHosts = dir: with builtins;
    mapAttrs
      (name: path:
        self.inputs.nixpkgs.lib.nixosSystem
          {
            modules = [
              self.outputs.nixosModules.default
              { os.hostname = name; }
              (path + "/default.nix")
              (path + "/hardware.nix")
            ];
          })
      (self.lib.getDirs dir);
in
mkHosts ../hosts
