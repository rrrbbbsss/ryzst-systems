{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ryzst.int.syncthing.server;
  enable = cfg.nodes?${config.networking.hostName};
  clientsIps =
    attrsets.foldlAttrs (acc: n: v: "${v.ip}, ${acc}") "" config.ryzst.int.syncthing.client.nodes;
  deviceConfigs = attrsets.foldlAttrs
    (acc: n: v: {
      ${n} = {
        id = v.keys.syncthing;
        addresses = [ "${cfg.protocol}://${v.ip}:${builtins.toString cfg.port}" ];
      };
    } // acc)
    { }
    cfg.nodes;
  inherit (config.ryzst.int.syncthing) client;
  clientDeviceNames = attrsets.foldlAttrs
    (acc: n: _: [ n ] ++ acc)
    [ ]
    client.deviceConfigs;
in
{
  options.ryzst.int.syncthing.server = {
    nodes = mkOption {
      description = "Nodes the client is deployed to";
      type = types.attrs;
      default = { };
    };
    ip = mkOption {
      description = "Ip to listen on";
      type = types.str;
      default = config.ryzst.mek.${config.networking.hostName}.ip;
    };
    port = mkOption {
      description = "Port to listen on";
      type = types.int;
      default = 22000;
    };
    protocol = mkOption {
      description = "Protocol to use";
      type = types.enum [ "tcp" "tcp4" "tcp6" "quic" "quic4" "quic6" ];
      # TODO: update to tcp6 when time comes
      default = "tcp4";
    };
    deviceConfigs = mkOption {
      description = "Device configuration information";
      type = types.attrs;
      default = deviceConfigs;
    };
    stateDir = mkOption {
      description = "Path to syncthing service state";
      type = types.path;
      default = "/persist/syncthing";
    };
    secretsDir = mkOption {
      description = "Path to syncthing service secrets";
      type = types.path;
      default = "/persist/syncthing/secrets";
    };
  };

  config = mkIf enable {
    networking.firewall.extraCommands = ''
      ${pkgs.nftables}/bin/nft add rule ip filter nixos-fw iifname "wg0" counter ip saddr { ${clientsIps} } tcp dport ${builtins.toString cfg.port} jump nixos-fw-accept
    '';

    services.syncthing = {
      enable = true;
      dataDir = cfg.stateDir;
      key = "${cfg.secretsDir}/key.pem";
      cert = "${cfg.secretsDir}/cert.pem";
      # TODO: gui listen on unix socket
      #guiAddress = "${cfg.ip}:8384";
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        options = {
          listenAddresses = [ "${cfg.protocol}://${cfg.ip}:${builtins.toString cfg.port}" ];
          globalAnnounceEnabled = false;
          localAnnounceEnabled = false;
          natEnabled = false;
          relaysEnabled = false;
          urAccepted = -1;
        };
        devices = client.deviceConfigs;
        folders = {
          # TODO: dont hardcode folder name for user homes
          "home-man" = {
            path = "${cfg.stateDir}/home-man";
            # TODO: compute based off devices assined to user
            devices = clientDeviceNames;
            type = "receiveonly";
            versioning = {
              type = "staggered";
              params = {
                maxAge = builtins.toString (180 * 86400);
                cleanupInterval = "3600";
              };
            };
          };
        };
      };
    };
  };
}
