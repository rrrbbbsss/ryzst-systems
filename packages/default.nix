{ pkgs, lib, ... }:

with pkgs; rec {
  default = cli;
  cli = callPackage ./cli { };
  sabaki = callPackage ./sabaki { };
  katrain = callPackage ./katrain { };
  katago-model = callPackage ./katago-model { };
  q5go = libsForQt5.callPackage ./q5go { };
  fzf-pass = callPackage ./fzf-pass { };
  fzf-wifi = callPackage ./fzf-wifi { };
  kivy = python3Packages.callPackage ./python-libs/kivy {
    inherit (pkgs) mesa;
    inherit (pkgs.darwin.apple_sdk.frameworks) ApplicationServices AVFoundation;
  };
  kivymd = python3Packages.callPackage ./python-libs/kivymd { };
  ffpyplayer = python3Packages.callPackage ./python-libs/ffpyplayer { };
}
// (lib.mkVMs ../hosts)
// (lib.mkISOs ../isos)