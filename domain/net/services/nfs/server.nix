{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ryzst.int.nfs.server;
  enable = cfg.nodes?${config.networking.hostName};
  clientsIps =
    attrsets.foldlAttrs (acc: n: v: "${v.ip}, ${acc}") "" config.ryzst.int.nfs.client.nodes;
in
{
  options.ryzst.int.nfs.server = {
    enable = mkEnableOption "Internal Nfs service";
    nodes = mkOption {
      description = "Nodes the service is deployed to";
      type = types.attrs;
      default = { };
    };
    interface = mkOption {
      description = "The interface to bind the service to";
      type = types.str;
      default = "wg0";
    };
    ip = mkOption {
      description = "The ip address to bind the service to";
      type = types.str;
      default = cfg.nodes.${config.networking.hostName}.ip;
    };
    port = mkOption {
      description = "The port for the service to listen on";
      type = types.int;
      default = 2049;
    };
    allow = mkOption {
      description = "The subnet to allow traffic from";
      type = types.str;
      default = config.os.subnet;
    };
  };
  config = mkIf enable {
    networking.firewall.extraInputRules = ''
      iifname "wg0" counter ip6 saddr { ${clientsIps} } tcp dport ${builtins.toString cfg.port} accept
    '';

    services.nfs.server = {
      enable = true;
      hostName = cfg.ip;
      extraNfsdConfig = ''
        vers3=no
      '';
      # cheat
      exports = ''
        /srv/nfs      ${cfg.allow}(rw,fsid=0,no_subtree_check)
        /srv/nfs/dump ${cfg.allow}(rw,nohide,insecure,no_subtree_check)
      '';
    };

    services.rpcbind.enable = mkForce false;
    systemd.services.rpc-statd.enable = mkForce false;
  };
}
