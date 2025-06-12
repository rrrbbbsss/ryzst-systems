self:
let
  # TODO: remove
  nixpkgs = self.inputs.nixpkgs or
    self.inputs.ryzst.inputs.nixpkgs;
  mkHosts = dir: with builtins;
    mapAttrs
      (name: path:
        nixpkgs.lib.nixosSystem
          {
            specialArgs = { inherit self; };
            modules = [
              self.outputs.nixosModules.default
              { os.hostname = name; }
              (path + "/default.nix")
              (path + "/hardware.nix")
            ];
          })
      (self.lib.getDirs dir);
in
mkHosts ./.
