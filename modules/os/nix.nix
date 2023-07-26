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
      # read manual:
      system.stateVersion = "22.11";
      # forgive me
      nixpkgs.config.allowUnfree = true;
      nix = {
        settings = {
          experimental-features = [ "nix-command" "flakes" ];
          auto-optimise-store = true;
          flake-registry = "";
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
