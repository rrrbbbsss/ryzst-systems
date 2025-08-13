{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ryzst.int.syncthing.reading;
  deviceConfigs = attrsets.foldlAttrs
    (acc: n: v: {
      ${n} = {
        id = v.keys.syncthing;
        addresses = [ "${cfg.protocol}://[${v.ip}]:${builtins.toString cfg.port}" ];
      };
    } // acc)
    { }
    cfg.nodes;
in
{
  options.ryzst.int.syncthing.reading = {
    nodes = mkOption {
      description = "Nodes the reading client is deployed to";
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
}
