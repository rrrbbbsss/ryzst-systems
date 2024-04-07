{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ryzst.int.cache.server;
  enable = cfg.nodes?${config.networking.hostName};
  clientsIps =
    attrsets.foldlAttrs (acc: n: v: "${v.ip}, ${acc}") ""
      config.ryzst.int.cache.client.nodes;
  clientsSSHKeys =
    attrsets.foldlAttrs (acc: n: v: [ v.keys.ssh ] ++ acc) [ ]
      config.ryzst.int.cache.client.nodes;
in
{
  options.ryzst.int.cache.server = {
    enable = mkEnableOption "Internal cache service";
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
      default = 22;
    };
  };
  config = mkIf enable {

    networking.firewall.extraCommands = ''
      ${pkgs.nftables}/bin/nft add rule ip6 filter nixos-fw iifname "wg0" counter ip6 saddr { ${clientsIps} } tcp dport ${builtins.toString cfg.port} jump nixos-fw-accept
    '';

    nix = {
      settings.allowed-users = [ "nix-ssh" ];
      sshServe = {
        enable = true;
        keys = clientsSSHKeys;
      };
    };
  };
}
