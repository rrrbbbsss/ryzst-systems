{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ryzst.int.ci.client-web;
  enable = cfg.nodes?${config.networking.hostName};
in
{
  options.ryzst.int.ci.client-web = {
    nodes = mkOption {
      description = "Nodes the web client is deployed to";
      type = types.attrs;
      default = { };
    };
  };

  config = mkIf enable {
    environment.systemPackages = [
      (pkgs.makeDesktopItem {
        name = "Laminar";
        exec = "${pkgs.xdg-utils}/bin/xdg-open http://ci.int.ryzst.net:${toString config.ryzst.int.ci.server.web-port}";
        desktopName = "Laminar";
        genericName = "Laminar";
        categories = [ "Development" ];
      })
    ];
  };
}
