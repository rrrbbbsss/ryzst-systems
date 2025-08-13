{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ryzst.int.ci.client-web;
  enable = cfg.nodes?${config.networking.hostName};
  server-certs = attrsets.foldlAttrs
    (acc: n: v: [ v.keys.x509 ] ++ acc)
    [ ]
    config.ryzst.int.ci.server.nodes;
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
        # TODO: fix hostname
        exec = "${pkgs.xdg-utils}/bin/xdg-open https://ci.tin-jet.mek.ryzst.net:${toString config.ryzst.int.ci.server.web-port}";
        desktopName = "Laminar";
        genericName = "Laminar";
        categories = [ "Development" ];
      })
    ];

    security.pki.certificates = server-certs;

    #TODO: remove after redo how dns records are generated
    networking.hosts = {
      "fd6a:f922:2250::e275" = [ "ci.tin-jet.mek.ryzst.net" ];
    };
  };
}
