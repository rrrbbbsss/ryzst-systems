{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ryzst.int.syncthing.client;
  enable = cfg.nodes?${config.networking.hostName};
  deviceConfigs = attrsets.foldlAttrs
    (acc: n: v: {
      ${n} = {
        id = v.keys.syncthing;
        addresses = [ "${cfg.protocol}://[${v.ip}]:${builtins.toString cfg.port}" ];
      };
    } // acc)
    { }
    cfg.nodes;
  inherit (config.ryzst.int.syncthing) server;
  serverDeviceNames = attrsets.foldlAttrs
    (acc: n: _: [ n ] ++ acc)
    [ ]
    server.deviceConfigs;
in
{
  options.ryzst.int.syncthing.client = {
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
      default = "tcp6";
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
      default = "/persist/secrets/syncthing";
    };
  };

  config = mkIf enable {
    environment.systemPackages = [
      (pkgs.makeDesktopItem {
        name = "Syncthing";
        exec = "${pkgs.xdg-utils}/bin/xdg-open localhost:8384";
        # TODO: icon = pname;
        desktopName = "Syncthing";
        genericName = "Syncthing";
        categories = [ "Settings" ];
        startupNotify = false;
      })
    ];

    systemd.tmpfiles.rules = [
      "L /home/${config.device.user}/.stignore - - - - ${pkgs.writeText "stignore" "/.*"}"
    ];

    services.syncthing = {
      enable = true;
      dataDir = cfg.stateDir;
      key = "${cfg.secretsDir}/key.pem";
      cert = "${cfg.secretsDir}/cert.pem";
      inherit (config.device) user;
      group = "users";
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        # TODO: gui listen on unix socket
        options = {
          listenAddresses = [ "${cfg.protocol}://[${cfg.ip}]:${builtins.toString cfg.port}" ];
          globalAnnounceEnabled = false;
          localAnnounceEnabled = false;
          natEnabled = false;
          relaysEnabled = false;
          urAccepted = -1;
        };
        devices = server.deviceConfigs;
        folders = {
          "home-${config.device.user}" = {
            path = "/home/${config.device.user}";
            devices = serverDeviceNames;
            type = "sendreceive";
            versioning = {
              type = "staggered";
              params = {
                maxAge = builtins.toString (21 * 86400);
                cleanupInterval = "3600";
              };
            };
          };
        };
      };
    };
  };
}
