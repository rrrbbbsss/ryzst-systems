{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ryzst.int.dns.server;
in
{
  options.ryzst.int.dns.server = {
    enable = mkEnableOption "Internal Dns service";
    interface = mkOption {
      description = "The interface to bind the service to";
      type = types.str;
      default = "wg0";
    };
    port = mkOption {
      description = "The port for the service to listen on";
      type = types.int;
      default = 53;
    };
    allow = mkOption {
      description = "The subnet to allow traffic from";
      type = types.str;
      default = "10.255.255.0/24";
    };
    resolvers = mkOption {
      description = "DNS resolvers to forward to";
      type = types.attrs;
      default = {
        primary = { ip = "1.1.1.1"; name = "cloudflare-dns.com"; };
        secondary = { ip = "8.8.8.8"; name = "dns.google"; };
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.interfaces = {
      ${cfg.interface} = {
        allowedUDPPorts = [ cfg.port ];
        allowedTCPPorts = [ cfg.port ];
      };
    };

    services.coredns = {
      enable = true;
      config = ''
        .:${builtins.toString cfg.port} {
          bind ${cfg.interface}
          acl {
            allow net ${cfg.allow}
            drop
          }
          hosts ${config.ryzst.mek.hostsFile} ${config.networking.domain} {
            ttl 3600
            fallthrough
          }
          forward . 127.0.0.1:5301 127.0.0.1:5302
          cache 3600
        }
        .:5301 { 
          bind 127.0.0.1
          forward . tls://${cfg.resolvers.primary.ip} {
            tls_servername ${cfg.resolvers.primary.name}
            health_check 5s
          }
        }
        .:5302 {
          bind 127.0.0.1
          forward . tls://${cfg.resolvers.secondary.ip} {
            tls_servername ${cfg.resolvers.secondary.name}
            health_check 5s
          }
        }
      '';
    };
  };
}
