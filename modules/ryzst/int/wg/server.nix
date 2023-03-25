{ config, lib, ... }:
with lib;
let
  cfg = config.ryzst.int.wg.server;
  enable = lists.any
    (x: x.name == config.networking.hostName)
    cfg.nodes;
  #todo: fix
  ip = (builtins.head cfg.nodes).ip;
  publicKey = (builtins.head cfg.nodes).keys.wg0;
  #todo: fix
  clients = attrsets.foldlAttrs
    (acc: n: v:
      [{ publicKey = v.keys.wg0; allowedIPs = [ "${v.ip}/32" ]; }] ++ acc)
    [ ]
    config.ryzst.mek.hosts;
in
{
  options.ryzst.int.wg.server = {
    nodes = mkOption {
      description = "Nodes the server is deployed to";
      type = types.listOf types.attrs;
      default = [ ];
    };
    ip = mkOption {
      description = "The ip address to bind the service to";
      type = types.str;
      default = ip;
    };
    publicKey = mkOption {
      description = "The publicKey of the interface";
      type = types.str;
      default = publicKey;
    };
    subnet = mkOption {
      description = "The subnet of the wireguard network";
      type = types.str;
      default = "10.255.255.0/24";
    };
    port = mkOption {
      description = "The port for the service to listen on";
      type = types.int;
      default = 51820;
    };
    endpoint = mkOption {
      description = "The ip address to bind the service to";
      type = types.str;
      # todo: don't set this here
      default = "192.168.0.1";
    };
  };

  config = mkIf enable {
    networking.wireguard.interfaces = {
      wg0 = {
        ips = [ "${cfg.ip}/24" ];
        listenPort = cfg.port;
        privateKeyFile = "/persist/secrets/wg0_key";
        peers = clients;
      };
    };
  };
}
