{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ryzst.int.ntp.server;
  enable = cfg.nodes?${config.networking.hostName};
  clientsIps =
    attrsets.foldlAttrs (acc: n: v: "${v.ip}, ${acc}") "" config.ryzst.int.ntp.client.nodes;
in
{
  options.ryzst.int.ntp.server = {
    enable = mkEnableOption "Internal Ntp service";
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
      default = "no";
    };
    port = mkOption {
      description = "The port for the service to listen on";
      type = types.int;
      default = 123;
    };
    allow = mkOption {
      description = "The subnet to allow traffic from";
      type = types.str;
      default = config.os.subnet;
    };
    nts-servers = mkOption {
      description = "NTS servers to sync to";
      type = with types; listOf str;
      default = [ "time.cloudflare.com" "oregon.time.system76.com" ];
    };
  };
  config = mkIf enable {

    networking.firewall.extraCommands = ''
      ${pkgs.nftables}/bin/nft add rule ip filter nixos-fw iifname "wg0" counter ip saddr { ${clientsIps} } udp dport ${builtins.toString cfg.port} jump nixos-fw-accept
    '';

    # NTP server
    services.chrony = {
      enable = true;
      enableNTS = true;
      serverOption = "iburst";
      servers = cfg.nts-servers;
      extraConfig = ''
        allow ${cfg.allow}
        bindaddress ${cfg.nodes.${config.networking.hostName}.ip}
        port ${builtins.toString cfg.port}
      '';
    };
  };
}
