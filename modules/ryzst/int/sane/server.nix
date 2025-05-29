{ config, lib, ... }:
with lib;
let
  cfg = config.ryzst.int.sane.server;
  enable = cfg.nodes?${config.networking.hostName};
  clientsIps =
    attrsets.foldlAttrs
      (acc: n: v: "${v.ip}, ${acc}")
      ""
      config.ryzst.int.sane.client.nodes;
  clients =
    attrsets.foldlAttrs
      (acc: n: v: "[${v.ip}]\n" + acc)
      ""
      config.ryzst.int.cups.client.nodes;
in
{
  options.ryzst.int.sane.server = {
    enable = mkEnableOption "Internal Sane service";
    nodes = mkOption {
      description = "Nodes the service is deployed to";
      type = types.attrs;
      default = { };
    };
    ip = mkOption {
      description = "The ip address to bind the service to";
      type = types.str;
      default = cfg.nodes.${config.networking.hostName}.ip;
    };
    port = mkOption {
      description = "The port for the service to listen on";
      type = types.int;
      default = 6566;
    };
    dataPortRange = mkOption {
      description = "The data port range for the service to listen on";
      type = types.str;
      default = "10000 - 10100";
    };
  };
  config = mkIf enable {

    networking.firewall.extraInputRules = ''
      iifname "wg0" counter ip6 saddr { ${clientsIps} } tcp dport ${builtins.toString cfg.port} accept
    '';
    networking.nftables.tables = {
      stateful-sane = {
        family = "inet";
        content = ''
          ct helper sane-standard {
              type "sane" protocol tcp;
          }

          chain PRE {
              type filter hook prerouting priority filter;
              iifname "wg0" tcp dport 6566 ct helper set "sane-standard"
          }

          chain IN {
              ct helper "sane" accept
          }
        '';
      };
    };

    hardware.sane.enable = true;
    services.saned = {
      enable = true;
      extraConfig = "data_portrange = ${cfg.dataPortRange}\n\n" + clients;
    };
    systemd.sockets.saned.listenStreams = mkForce [
      "[${cfg.ip}]:${toString cfg.port}"
    ];
  };
}
