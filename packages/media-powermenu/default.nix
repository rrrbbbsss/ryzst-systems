{ pkgs, ... }:
{
  # TODO: use callPackage
  ${builtins.baseNameOf ./.} =
    pkgs.python3Packages.callPackage ./package.nix { };
}
