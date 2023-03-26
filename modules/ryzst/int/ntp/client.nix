{ config, lib, ... }:
with lib;
let
  cfg = config.ryzst.int.ntp.client;
  enable = cfg.nodes?${config.networking.hostName};
in
{
  options.ryzst.int.ntp.client = {
    nodes = mkOption {
      description = "Nodes the client is deployed to";
      type = types.attrs;
      default = [ ];
    };
  };

  config = mkIf enable {
    #todo: would rather look up fqdn
    networking.timeServers = [ "ntp.int.ryzst.net" ];
  };
}
