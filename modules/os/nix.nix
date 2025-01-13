{ config, lib, ... }:
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
      # forgive me
      nixpkgs.config.allowUnfree = true;
      nix = {
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
      system = {
        autoUpgrade = {
          enable = true;
          persistent = true;
          randomizedDelaySec = "30min";
          dates = "daily";
          allowReboot = true;
          inherit (config.os) flake;
        };
      };
    })
  ];
}
