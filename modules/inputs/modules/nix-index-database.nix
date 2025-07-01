{ pkgs, ... }:
{
  programs.nix-index.package = pkgs.nix-index-with-db;
}
