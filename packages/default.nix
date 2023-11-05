{ pkgs, ryzst, lib, system, ... }:

let
  packages = with pkgs; {
    default = ryzst.apps;
    apps = callPackage ./apps { inherit pkgs ryzst; };
    sabaki = callPackage ./sabaki { };
    katrain = callPackage ./katrain { inherit ryzst; };
    katago-model = callPackage ./katago-model { };
    q5go = libsForQt5.callPackage ./q5go { };
    fzf-pass = callPackage ./fzf/pass { };
    fzf-wifi = callPackage ./fzf/wifi { };
    fzf-sway-windows = callPackage ./fzf/sway-windows { };
    kivymd = python3Packages.callPackage ./python-libs/kivymd { };
    ffpyplayer = python3Packages.callPackage ./python-libs/ffpyplayer { };
    media-powermenu = python3Packages.callPackage ./media-powermenu { };
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
