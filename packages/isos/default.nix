{ self, pkgs, ... }:
import ./package.nix { inherit self; }
