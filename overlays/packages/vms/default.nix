{ pkgs, self, ... }:
import ./package.nix { inherit pkgs self; }
