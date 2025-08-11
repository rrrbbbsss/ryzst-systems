{ self, pkgs, ... }:
import ./package.nix { inherit self pkgs; }
