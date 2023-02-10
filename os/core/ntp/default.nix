{ config, pkgs, ... }:
{
  # NTP client
  time.timeZone = "America/Chicago";
  networking.timeServers = [ "ntp.int.ryzst.net" ];
}