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
  config = mkIf cfg.enable {
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
      # read manual:
      stateVersion = "22.11";
      autoUpgrade = {
        enable = true;
        persistent = true;
        randomizedDelaySec = "30min";
        dates = "daily";
        allowReboot = true;
        flake = config.os.flake;
      };
    };
    # forgive me
    nixpkgs.config.allowUnfree = true;
  };
}
