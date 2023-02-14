{ pkgs, ... }:

with pkgs; rec {
  default = cli;
  cli = callPackage ./cli { };
  sabaki = callPackage ./sabaki { };
  katrain = callPackage ./katrain { };
  katago-model = callPackage ./katago-model { };
  q5go = with libsForQt5; callPackage ./q5go { };
  fzf-pass = callPackage ./fzf-pass { };
  fzf-wifi = callPackage ./fzf-wifi { };
  python-libs = with python3Packages; {
    kivy = callPackage ./python-libs/kivy {
      inherit (pkgs) mesa;
      inherit (pkgs.darwin.apple_sdk.frameworks) ApplicationServices AVFoundation;
    };
    kivymd = callPackage ./python-libs/kivymd { };
    ffpyplayer = callPackage ./python-libs/ffpyplayer { };
  };
}
