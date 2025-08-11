{ pkgs, ... }:
{
  ${builtins.baseNameOf ./.} =
    pkgs.libsForQt5.callPackage ./package.nix { };
}
