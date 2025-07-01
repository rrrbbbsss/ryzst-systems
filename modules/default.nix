self:
# TODO: clean this up...
let
  default-imports = [
    #self
    ./ryzst
    self.nixosModules.default
    ./settings
    # TODO: think about better place for this
    (import ./inputs self).default
  ];
in
{
  default = { config, pkgs, self, ... }:
    {
      imports = default-imports;

      config = {
        os = {
          locale = "en_US.UTF-8";
          timezone = "America/Chicago";
          domain = "mek.ryzst.net";
          flake = "git+ssh://git@git.int.ryzst.net/domain";
        };

        # TODO: i'd like for there to be just one registry...
        nix.registry = {
          ryzst-systems.flake = self;
        } // (builtins.mapAttrs (n: v: { flake = self.inputs.${n}; }) self.inputs);

      };
    };
}
