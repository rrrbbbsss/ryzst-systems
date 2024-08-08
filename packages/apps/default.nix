{ pkgs, ryzst, ... }:
{
  ${builtins.baseNameOf ./.} =
    pkgs.callPackage ./package.nix { inherit ryzst; };
}
