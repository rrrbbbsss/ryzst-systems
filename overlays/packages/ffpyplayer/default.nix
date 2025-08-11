{ pkgs, ... }:
{
  ${builtins.baseNameOf ./.} =
    pkgs.python3Packages.callPackage ./package.nix { };
}
