{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ryzst.int.dns.server;
  enable = cfg.nodes?${config.networking.hostName};
  nameservers =
    attrsets.foldlAttrs (acc: n: v: [ v.ip ] ++ acc) [ ] config.ryzst.int.dns.server.nodes;
  clientsIps =
    attrsets.foldlAttrs (acc: n: v: "${v.ip}, ${acc}") "" config.ryzst.int.dns.client.nodes;
  hostsFiles =
    let
      entries = x: y: attrsets.foldlAttrs (acc: n: v: "${v.ip} ${x}.int.ryzst.net\n${acc}") "" y;
    in
    {
      int = with builtins;
        toFile "int-hostsFile"
          (attrsets.foldlAttrs
            (acc: n: v: "${entries n v.server.nodes}\n${acc}") ""
            config.ryzst.int);
      mek = with builtins;
        toFile "mek-hostsFile"
          (attrsets.foldlAttrs
            (acc: n: v: "${v.ip} ${n}.mek.ryzst.net\n${acc}") ""
            config.ryzst.mek);
    };
in
{
  options.ryzst.int.dns.server = {
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
    nameservers = mkOption {
      description = "List of nameserver IPs";
      type = types.listOf types.str;
      default = nameservers;
    };
  };

  config = mkIf enable {
    networking.nameservers = cfg.nameservers;

    networking.firewall.extraCommands = ''
      ${pkgs.nftables}/bin/nft add rule ip filter nixos-fw iifname "wg0" counter ip saddr { ${clientsIps} } udp dport ${builtins.toString cfg.port} jump nixos-fw-accept
      ${pkgs.nftables}/bin/nft add rule ip filter nixos-fw iifname "wg0" counter ip saddr { ${clientsIps} } tcp dport ${builtins.toString cfg.port} jump nixos-fw-accept
    '';

    services.coredns = {
      enable = true;
      config = ''
        .:${builtins.toString cfg.port} {
          bind ${cfg.interface}
          acl {
            allow net ${cfg.allow}
            drop
          }
          hosts ${hostsFiles.int} "int.ryzst.net" {
            ttl 3600
            fallthrough
          }
          hosts ${hostsFiles.mek} "mek.ryzst.net" {
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
