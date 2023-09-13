{ config, ... }:
{
  # network manager
  users.users.${config.device.user}.extraGroups = [ "networkmanager" ];
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "none";
}
