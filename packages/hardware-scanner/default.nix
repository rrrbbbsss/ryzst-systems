{ pkgs, self, ... }:
{
  # TODO: get hardware id info from self
  ${builtins.baseNameOf ./.} =
    pkgs.callPackage ./package.nix { };
}
