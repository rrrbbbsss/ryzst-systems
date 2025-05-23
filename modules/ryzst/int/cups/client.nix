{ config, lib, ... }:
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

  # TODO: add .desktop file for cups
  # TODO: tls
  config = mkIf enable {
    services.printing = {
      enable = true;
      listenAddresses = [ "localhost:631" ];
    };
    hardware.printers.ensurePrinters = printers;
  };
}
