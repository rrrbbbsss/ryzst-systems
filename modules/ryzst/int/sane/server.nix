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
  };
  config = mkIf enable {

    networking.firewall.extraInputRules = ''
      iifname "wg0" counter ip6 saddr { ${clientsIps} } tcp dport ${builtins.toString cfg.port} accept
    '';

    hardware.sane.enable = true;
    services.saned = {
      enable = true;
      extraConfig = clients;
    };
    systemd.sockets.saned.listenStreams = mkForce [
      "[${cfg.ip}]:${toString cfg.port}"
    ];
  };
}
