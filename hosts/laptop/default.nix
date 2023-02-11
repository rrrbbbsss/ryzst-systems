{ config, pkgs, home-manager, lib, ... }:

{
  networking.hostName = builtins.baseNameOf ./.;

  users.mutableUsers = false;
  users.users.root.initialPassword = "*";
}
