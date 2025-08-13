{ config, lib, ... }:
with lib;
let
  cfg = config.ryzst.int.wg.server;
  enable = cfg.nodes?${config.networking.hostName};
  inherit (config.ryzst.mek.${config.networking.hostName}) ip;
  configs = attrsets.foldlAttrs
    (acc: n: v:
      [{
        PublicKey = v.keys.wg0;
        AllowedIPs = [ cfg.subnet ];
        Endpoint = "${n}.local:${builtins.toString cfg.port}";
        PersistentKeepalive = 10;
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
      default = config.os.subnet;
    };
    port = mkOption {
      description = "The port for the service to listen on";
      type = types.int;
      default = 51820;
    };
    ip = mkOption {
      description = "The ip address for the server to use";
      type = types.str;
      default = ip;
    };
    address = mkOption {
      description = "The address for the server to use";
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

    services.resolved.extraConfig = lib.mkForce ''
      MulticastDNS=true
    '';

    networking.firewall.allowedUDPPorts = [
      cfg.port
    ];

    networking.firewall.filterForward = true;
    # TODO: tighten
    networking.firewall.extraForwardRules = ''
      iifname wg0 oifname wg0 accept
    '';

    # ip forwarding 
    boot.kernel.sysctl = {
      "net.ipv6.conf.all.forwarding" = true;
    };

    systemd.services.systemd-networkd.serviceConfig.LoadCredential = [
      "wg0:/persist/secrets/wg0_key"
    ];
    systemd.network = {
      netdevs = {
        "wg0" = {
          netdevConfig = {
            Kind = "wireguard";
            Name = "wg0";
            MTUBytes = "1420";
          };
          wireguardConfig = {
            PrivateKey = "@wg0";
            ListenPort = cfg.port;
          };
          wireguardPeers = config.ryzst.int.wg.client.configs;
        };
      };
      networks = {
        wg0 = {
          matchConfig.Name = "wg0";
          networkConfig = {
            Address = cfg.address;
            DHCP = false;
            IPv6AcceptRA = false;
            MulticastDNS = false;
          };
        };
        wired.networkConfig.MulticastDNS = lib.mkForce true;
      };
    };
  };
}
