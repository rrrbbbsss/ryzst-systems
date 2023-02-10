{ config, pkgs, ... }:
{
  # Printing client
  services.printing = {
    enable = true;
  };
}