{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ryzst.int.cups.client;
  enable = cfg.nodes?${config.networking.hostName};
  serverPort = config.ryzst.int.cups.server.port;
  printers = attrsets.foldlAttrs
    (acc: n: v: [{
      name = "todo";
      location = "todo";
      model = "everywhere";
      deviceUri =
        "ipp://[${v.ip}]:${toString serverPort}/printers/brother";
    }] ++ acc)
    [ ]
    config.ryzst.int.cups.server.nodes;
in
{
  options.ryzst.int.cups.client = {
    nodes = mkOption {
      description = "Nodes the client is deployed to";
      type = types.attrs;
      default = { };
    };
  };

  # TODO: tls
  config = mkIf enable {
    environment.systemPackages = [
      (pkgs.makeDesktopItem {
        name = "Cups";
        exec = "${pkgs.xdg-utils}/bin/xdg-open http://localhost:631";
        desktopName = "Cups";
        genericName = "Cups";
        categories = [ "Office" ];
      })
    ];
    services.printing = {
      enable = true;
      listenAddresses = [ "localhost:631" ];
    };
    hardware.printers.ensurePrinters = printers;
    systemd.services.ensure-printers.serviceConfig = {
      # TODO: Fix this properly
      ExecStartPre = mkBefore [ "${pkgs.coreutils-full}/bin/sleep 5" ];
    };
  };
}
