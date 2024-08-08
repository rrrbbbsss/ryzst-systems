{ pkgs, ... }:
{
  ${builtins.baseNameOf ./.} =
    pkgs.callPackage ./package.nix { };
}
