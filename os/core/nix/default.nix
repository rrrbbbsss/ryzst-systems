{ config, pkgs, ... }:
{
  config = {
    # forgive me
    nixpkgs.config.allowUnfree = true;
    # general:
    nix = {
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store = true;
        cores = 12;
      };
      extraOptions = ''
        keep-outputs = true
        keep-derivations = true
      '';
    };
    # autoupgrades: todo...
    system.autoUpgrade = {
      enable = false;
      persistent = true;
      randomizedDelaySec = "30min";
      dates = "daily";
      allowReboot = false;
      flake = "github:rrrbbbsss/ryzst-systems";
    };
    # garbage:
    nix.gc = {
      automatic = true;
      persistent = true;
      randomizedDelaySec = "30min";
      dates = "weekly";
      options = ''
        --delete-older-than 30d;
      '';
    };
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "22.11"; # Did you read the comment?
  };
}
