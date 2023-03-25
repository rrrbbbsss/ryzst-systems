{ config, lib, ... }:
with lib;
let
  cfg = config.ryzst.int.ntp.client;
  enable = lists.any
    (x: x.name == config.networking.hostName)
    cfg.nodes;
in
{
  options.ryzst.int.ntp.client = {
    nodes = mkOption {
      description = "Nodes the client is deployed to";
      type = types.listOf types.attrs;
      default = [ ];
    };
  };

  config = mkIf enable {
    networking.timeServers = [ "ntp.int.ryzst.net" ];
  };
}
