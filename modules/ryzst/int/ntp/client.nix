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
      default = { };
    };
  };

  config = mkIf enable {
    networking.timeServers = [ "ntp.int.ryzst.net" ];
    services.timesyncd.extraConfig = ''
      FallbackNTP=""
    '';
  };
}
