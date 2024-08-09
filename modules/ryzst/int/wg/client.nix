{ config, lib, ... }:
with lib;
let
  cfg = config.ryzst.int.wg.client;
  enable = cfg.nodes?${config.networking.hostName};
  inherit (config.ryzst.mek.${config.networking.hostName}) ip;
  configs = attrsets.foldlAttrs
    (acc: n: v:
      [{
        wireguardPeerConfig = {
          PublicKey = v.keys.wg0;
          AllowedIPs = [ "${v.ip}/128" ];
        };
      }] ++ acc
    )
    [ ]
    cfg.nodes;
  inherit (config.ryzst.int.wg) server;
in
{
  options.ryzst.int.wg.client = {
    nodes = mkOption {
      description = "Nodes the client is deployed to";
      type = types.attrs;
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
      default = "${cfg.ip}/48";
    };
    configs = mkOption {
      description = "The configs of the service endpoints";
      type = types.listOf types.attrs;
      default = configs;
    };
  };

  config = mkIf enable {
    systemd.network = {
      netdevs = {
        "wg0" = {
          netdevConfig = {
            Kind = "wireguard";
            Name = "wg0";
            MTUBytes = "1420";
          };
          wireguardConfig = {
            PrivateKeyFile = "/persist/secrets/wg0_key";
            ListenPort = cfg.port;
          };
          wireguardPeers = server.configs;
        };
      };
      networks.wg0 = {
        matchConfig.Name = "wg0";
        networkConfig = {
          Address = cfg.address;
          DHCP = false;
          IPv6AcceptRA = false;
          MulticastDNS = false;
        };
      };
    };
  };
}
