{ pkgs, ... }:
{
  ${builtins.baseNameOf ./.} =
    pkgs.callPackage ./package.nix {
      inherit (pkgs.emacs.pkgs) trivialBuild;
    };
}
