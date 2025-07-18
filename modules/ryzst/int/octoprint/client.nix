{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ryzst.int.octoprint.client;
  enable = cfg.nodes?${config.networking.hostName};
  serverPort = config.ryzst.int.octoprint.server.port;
  desktopItems = foldlAttrs
    (acc: n: v:
      [
        (pkgs.makeDesktopItem {
          name = "OctoPrint";
          exec = "${pkgs.xdg-utils}/bin/xdg-open http://[${v.ip}]:${toString serverPort}";
          desktopName = "OctoPrint";
          genericName = "OctoPrint";
          categories = [ "Office" ];
        })
      ] ++ acc)
    [ ]
    config.ryzst.int.octoprint.server.nodes;
in
{
  options.ryzst.int.octoprint.client = {
    nodes = mkOption {
      description = "Nodes the client is deployed to";
      type = types.attrs;
      default = { };
    };
  };

  config = mkIf enable {
    environment.systemPackages = desktopItems ++ [
      pkgs.orca-slicer
    ];
  };
}
