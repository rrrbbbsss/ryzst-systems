{ config, lib, ... }:
with lib;
let
  cfg = config.ryzst.int.dns.client;
  enable = cfg.nodes?${config.networking.hostName};
in
{
  options.ryzst.int.dns.client = {
    nodes = mkOption {
      description = "Nodes the client is deployed to";
      type = types.attrs;
      default = { };
    };
  };

  config = mkIf enable {
    # todo: remove once old fw is replaced
    networking.nameservers = [ "10.0.2.1" ] ++ config.ryzst.int.dns.server.nameservers;
  };
}
