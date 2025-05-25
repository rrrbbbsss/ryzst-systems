{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ryzst.int.cups.server;
  enable = cfg.nodes?${config.networking.hostName};
  clientsIps =
    attrsets.foldlAttrs
      (acc: n: v: "${v.ip}, ${acc}")
      ""
      config.ryzst.int.cups.client.nodes;
  clientsIpsList =
    attrsets.foldlAttrs
      (acc: n: v: [ "[${v.ip}]" ] ++ acc)
      [ ]
      config.ryzst.int.cups.client.nodes;
in
{
  options.ryzst.int.cups.server = {
    enable = mkEnableOption "Internal Cups service";
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
      default = 631;
    };
  };
  config = mkIf enable {

    networking.firewall.extraInputRules = ''
      iifname "wg0" counter ip6 saddr { ${clientsIps} } tcp dport ${builtins.toString cfg.port} accept
    '';

    # TODO: tls
    services.printing = {
      enable = true;
      defaultShared = true;
      listenAddresses = [
        "${cfg.ip}:${toString cfg.port}"
      ];
      allowFrom = clientsIpsList;
      extraConf = ''
        ServerAlias [${cfg.ip}]
      '';
    };

    # TODO: Fix this properly
    systemd.services.cups.serviceConfig = {
      ExecStartPre = mkBefore [ "${pkgs.coreutils-full}/bin/sleep 5" ];
    };
  };
}
