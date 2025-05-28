{ config, lib, ... }:
with lib;
let
  cfg = config.ryzst.int.octoprint.server;
  enable = cfg.nodes?${config.networking.hostName};
  clientsIps =
    attrsets.foldlAttrs
      (acc: n: v: "${v.ip}, ${acc}")
      ""
      config.ryzst.int.octoprint.client.nodes;
in
{
  options.ryzst.int.octoprint.server = {
    enable = mkEnableOption "Internal Octopring service";
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
      default = 5000;
    };
  };
  config = mkIf enable {

    networking.firewall.extraInputRules = ''
      iifname "wg0" counter ip6 saddr { ${clientsIps} } tcp dport ${builtins.toString cfg.port} accept
    '';

    # TODO: tls
    services.octoprint = {
      enable = true;
      plugins = plugins: with plugins; [
        themeify
      ];
      host = "[${cfg.ip}]";
      inherit (cfg) port;
      # TODO: extraConfig
    };

  };
}
