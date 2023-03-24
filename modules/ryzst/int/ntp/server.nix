{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.ryzst.int.ntp.server;
in
{
  options.ryzst.int.ntp.server = {
    enable = mkEnableOption "Internal Ntp service";
    interface = mkOption {
      description = "The interface to bind the service to";
      type = types.str;
      default = "wg0";
    };
    address = mkOption {
      description = "The address to bind the service to";
      type = types.str;
      example = "10.255.255.1";
    };
    port = mkOption {
      description = "The port for the service to listen on";
      type = types.int;
      default = 123;
    };
    allow = mkOption {
      description = "The subnet to allow traffic from";
      type = types.str;
      default = "10.255.255.0/24";
    };
    nts-servers = mkOption {
      description = "NTS servers to sync to";
      type = with types; listOf str;
      default = [ "time.cloudflare.com" "oregon.time.system76.com" ];
    };
  };
  config = mkIf cfg.enable {
    networking.firewall.interfaces = {
      ${cfg.interface} = {
        allowedUDPPorts = [ cfg.port ];
      };
    };
    # NTP server
    services.chrony = {
      enable = true;
      enableNTS = true;
      serverOption = "iburst";
      servers = cfg.nts-servers;
      extraConfig = ''
        allow ${cfg.allow}
        bindaddress ${cfg.address}
        port ${builtins.toString cfg.port}
      '';
    };
  };
}
