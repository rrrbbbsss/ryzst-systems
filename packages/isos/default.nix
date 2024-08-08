{ system, self, ... }:
import ./package.nix { inherit system self; }
