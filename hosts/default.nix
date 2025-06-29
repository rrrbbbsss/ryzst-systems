self:
let
  inherit (self.inputs.ryzst.inputs) nixpkgs;
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
              ({ config, ... }: { nixpkgs.pkgs = self.instances.${config.nixpkgs.hostPlatform.system}; })
            ];
          })
      (self.lib.getDirs dir);
in
mkHosts ./.
