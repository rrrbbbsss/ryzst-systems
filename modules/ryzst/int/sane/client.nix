{ config, lib, ... }:
with lib;
let
  cfg = config.ryzst.int.sane.client;
  enable = cfg.nodes?${config.networking.hostName};
  scanners = attrsets.foldlAttrs
    (acc: n: v: "${v.ip}\n" + acc)
    ""
    config.ryzst.int.sane.server.nodes;
in
{
  options.ryzst.int.sane.client = {
    nodes = mkOption {
      description = "Nodes the client is deployed to";
      type = types.attrs;
      default = { };
    };
  };

  config = mkIf enable {
    hardware.sane = {
      enable = true;
      netConf = scanners;
    };
  };
}
