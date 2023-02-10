{ config, pkgs, home-manager, lib, ... }:

{
  os = {
    base = {
      hostname = builtins.baseNameOf ./.;
      locale = "en_US.UTF-8";
      timezone = "America/Chicago";
      admins = "todo";
      stateVersion = "22.11";
    };
  };


}
