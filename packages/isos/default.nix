{ system, self, pkgs, ... }:
import ./package.nix { inherit system self; }
