{ config, lib, self, ... }:
with lib;
let
  cfg = config.os.nix;
in
{
  options.os.nix = {
    enable = mkOption {
      type = types.bool;
      default = true;
      defaultText = literalExpression true;
      description = "whether to enable default nix options";
    };
  };
  config = mkMerge [
    {
      nix = {
        # TODO: i'd like for there to be just one registry...
        registry = {
          ryzst-systems.flake = self;
        } // (builtins.mapAttrs (n: v: { flake = self.inputs.${n}; }) self.inputs);
        channel.enable = false;
        settings = {
          secret-key-files = "/persist/secrets/nix/nix_key";
          experimental-features = [ "nix-command" "flakes" ];
          tarball-ttl = 0;
          auto-optimise-store = true;
          flake-registry = "";
          allowed-users = [ "@wheel" ];
          trusted-users = [ "root" ];
        };
        extraOptions = ''
          keep-outputs = true
          keep-derivations = true
        '';
      };
    }
    (mkIf cfg.enable {
      nix = {
        gc = {
          automatic = true;
          persistent = true;
          randomizedDelaySec = "30min";
          dates = "weekly";
          options = ''
            --delete-older-than 21d;
          '';
        };
      };
    })
  ];
}
