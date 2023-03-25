{ config, lib, ... }:
with lib;
let
  cfg = config.ryzst.int.dns.client;
  enable = lists.any
    (x: x.name == config.networking.hostName)
    cfg.nodes;
in
{
  options.ryzst.int.dns.client = {
    nodes = mkOption {
      description = "Nodes the client is deployed to";
      type = types.listOf types.attrs;
      default = [ ];
    };
  };

  config = mkIf enable {
    networking.nameservers = [ "10.0.2.1" ] ++ config.ryzst.int.dns.server.nameservers;
  };
}
