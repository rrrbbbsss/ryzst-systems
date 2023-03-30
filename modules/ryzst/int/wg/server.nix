{ config, lib, ... }:
with lib;
let
  cfg = config.ryzst.int.wg.server;
  enable = cfg.nodes?${config.networking.hostName};
  configs = attrsets.foldlAttrs
    (acc: n: v:
      [{
        publicKey = v.keys.wg0;
        allowedIPs = [ cfg.subnet ];
        endpoint = "${v.endpoint}:${builtins.toString cfg.port}";
        persistentKeepalive = 10;
      }] ++ acc
    )
    [ ]
    cfg.nodes;
in
{
  options.ryzst.int.wg.server = {
    nodes = mkOption {
      description = "Nodes the server is deployed to";
      type = types.attrs;
      default = [ ];
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
    configs = mkOption {
      description = "The configs of the service endpoints";
      type = types.listOf types.attrs;
      default = configs;
    };
  };

  config = mkIf enable {

    networking.firewall.allowedUDPPorts = [ cfg.port ];

    # ip forwarding 
    boot.kernel.sysctl = {
      "net.ipv4.conf.allforwarding" = true;
    };

    networking.wireguard.interfaces = {
      wg0 = {
        ips = [ "${cfg.nodes.${config.networking.hostName}.ip}/24" ];
        listenPort = cfg.port;
        privateKeyFile = "/persist/secrets/wg0_key";
        peers = config.ryzst.int.wg.client.configs;
      };
    };
  };
}
