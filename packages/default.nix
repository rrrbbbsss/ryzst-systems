{ pkgs, ryzst, lib, system, ... }:

let
  packages = with pkgs; {
    default = ryzst.cli;
    cli = callPackage ./cli { inherit ryzst; };
    apps = callPackage ./apps { inherit pkgs; };
    sabaki = callPackage ./sabaki { };
    katrain = callPackage ./katrain { inherit ryzst; };
    katago-model = callPackage ./katago-model { };
    q5go = libsForQt5.callPackage ./q5go { };
    fzf-pass = callPackage ./fzf-pass { };
    fzf-wifi = callPackage ./fzf-wifi { };
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
      inherit (packages) cli fzf-pass fzf-wifi;
    };
  };
in
target.${system}
