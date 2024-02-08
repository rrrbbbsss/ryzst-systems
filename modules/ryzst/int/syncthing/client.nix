{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ryzst.int.syncthing.client;
  enable = cfg.nodes?${config.networking.hostName};
  deviceConfigs = attrsets.foldlAttrs
    (acc: n: v: {
      ${n} = {
        id = v.keys.syncthing;
        addresses = [ "${cfg.protocol}://${v.ip}:${builtins.toString cfg.port}" ];
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
      default = "/home/${config.device.user}/.syncthing";
    };
    secretsDir = mkOption {
      description = "Path to syncthing service secrets";
      type = types.path;
      default = "/persist/secrets/syncthing";
    };
  };

  config = mkIf enable {
    # TODO: redo and simplify this
    home-manager.users.${config.device.user} = { pkgs, ... }: {
      home.persistence."/persist/home/${config.device.user}/.syncthing" = {
        removePrefixDirectory = true;
        directories = [
          { directory = "${config.device.user}/Code"; method = "symlink"; }
          { directory = "${config.device.user}/Documents"; method = "symlink"; }
          { directory = "${config.device.user}/Downloads"; method = "symlink"; }
          { directory = "${config.device.user}/Pictures"; method = "symlink"; }
          { directory = "${config.device.user}/Projects"; method = "symlink"; }
          { directory = "${config.device.user}/Notes"; method = "symlink"; }
          { directory = "${config.device.user}/Reading"; method = "symlink"; }
        ];
      };
    };
    environment.persistence."/persist" = {
      users.${config.device.user} = {
        directories = [
          ".syncthing"
        ];
      };
    };


    environment.systemPackages = [
      (pkgs.makeDesktopItem {
        name = "Syncthing";
        exec = "${config.home-manager.users.${config.device.user}.programs.firefox.package}/bin/firefox localhost:8384";
        # TODO: icon = pname;
        desktopName = "Syncthing";
        genericName = "Syncthing";
        categories = [ "Settings" ];
        startupNotify = false;
      })
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
          listenAddresses = [ "${cfg.protocol}://${cfg.ip}:${builtins.toString cfg.port}" ];
          globalAnnounceEnabled = false;
          localAnnounceEnabled = false;
          natEnabled = false;
          relaysEnabled = false;
          urAccepted = -1;
        };
        devices = server.deviceConfigs;
        folders = {
          ${config.device.user} = {
            path = "${cfg.stateDir}/${config.device.user}";
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
