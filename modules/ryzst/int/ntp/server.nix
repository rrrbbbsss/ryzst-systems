{ config, lib, ... }:
with lib;
let
  cfg = config.ryzst.int.ntp.server;
  enable = lists.any
    (x: x.name == config.networking.hostName)
    cfg.nodes;
  ip = builtins.getAttr "ip"
    (lists.findFirst
      (x: x.name == config.networking.hostName) ""
      config.ryzst.int.ntp.server.nodes);
in
{
  options.ryzst.int.ntp.server = {
    enable = mkEnableOption "Internal Ntp service";
    nodes = mkOption {
      description = "Nodes the service is deployed to";
      type = types.listOf types.attrs;
      default = [ ];
    };
    interface = mkOption {
      description = "The interface to bind the service to";
      type = types.str;
      default = "wg0";
    };
    ip = mkOption {
      description = "The ip address to bind the service to";
      type = types.str;
      default = ip;
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
  config = mkIf enable {
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
        bindaddress ${cfg.ip}
        port ${builtins.toString cfg.port}
      '';
    };
  };
}
