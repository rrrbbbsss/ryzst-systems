{ config, pkgs, ... }:
{
  # DNS client
  networking.nameservers = [ "10.0.2.1" ];
}
