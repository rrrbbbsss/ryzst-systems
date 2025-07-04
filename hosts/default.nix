self:
let
  inherit (self.inputs.ryzst.inputs) nixpkgs;
  mkHosts = dir: with builtins;
    mapAttrs
      (name: path:
        nixpkgs.lib.nixosSystem
          {
            # TODO: like to remove self as special arg
            # it is easy for consuming,
            # but not good for sharing.
            specialArgs = { inherit self; };
            modules = [
              self.outputs.settingsModules.default
              { os.hostname = name; }
              (path + "/default.nix")
              (path + "/hardware.nix")
              ({ config, ... }: { nixpkgs.pkgs = self.instances.${config.nixpkgs.hostPlatform.system}; })
            ];
          })
      (self.lib.getDirs dir);
in
mkHosts ./.
