{ pkgs, ryzst, hm, lib, system, ... }:

let
  packages = with pkgs; {
    default = ryzst.apps;
    apps = callPackage ./apps { inherit pkgs; };
    sabaki = callPackage ./sabaki { };
    katrain = callPackage ./katrain { inherit ryzst; };
    katago-model = callPackage ./katago-model { };
    q5go = libsForQt5.callPackage ./q5go { };
    fzf-pass = callPackage ./fzf/fzf-pass { };
    fzf-wifi = callPackage ./fzf/fzf-wifi { };
    fzf-nix-options = callPackage ./fzf/fzf-nix-options { inherit hm; };
    kivy = python3Packages.callPackage ./python-libs/kivy {
      inherit (pkgs) mesa;
      inherit (pkgs.darwin.apple_sdk.frameworks) ApplicationServices AVFoundation;
    };
    kivymd = python3Packages.callPackage ./python-libs/kivymd { inherit ryzst; };
    ffpyplayer = python3Packages.callPackage ./python-libs/ffpyplayer { };
    catppuccin-zathura = callPackage ./catppuccin/zathura { };
    catppuccin-alacritty = callPackage ./catppuccin/alacritty { };
  };
  target = {
    x86_64-linux = packages
      // (lib.mkVMs ../hosts)
      // (lib.mkISOs ../isos);
    aarch64-linux = {
      inherit (packages) apps fzf-pass fzf-wifi fzf-nix-options;
    };
  };
in
target.${system}
