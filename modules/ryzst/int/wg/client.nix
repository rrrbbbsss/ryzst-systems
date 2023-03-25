{ config, lib, ... }:
with lib;
let
  cfg = config.ryzst.int.wg.client;
  ip = config.ryzst.mek.hosts.${config.networking.hostName}.ip;

  server = config.ryzst.int.wg.server;
  enable = lists.any
    (x: x.name == config.networking.hostName)
    cfg.nodes;
in
{
  options.ryzst.int.wg.client = {
    nodes = mkOption {
      description = "Nodes the client is deployed to";
      type = types.listOf types.attrs;
      default = [ ];
    };
    port = mkOption {
      description = "The port for the service to listen on";
      type = types.int;
      default = 51820;
    };
    ip = mkOption {
      description = "The ip address for the client to use";
      type = types.str;
      default = ip;
    };
    address = mkOption {
      description = "The address for the client to use";
      type = types.str;
      default = "${cfg.ip}/24";
    };
  };

  config = mkIf enable {
    networking.wireguard.interfaces = {
      wg0 = {
        ips = [ "${cfg.address}" ];
        listenPort = cfg.port;
        privateKeyFile = "/persist/secrets/wg0_key";
        peers = [
          {
            publicKey = server.publicKey;
            allowedIPs = [ server.subnet ];
            endpoint = "${server.endpoint}:${builtins.toString server.port}";
            persistentKeepalive = 10;
          }
        ];
      };
    };
  };
}
