{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ryzst.int.ci.client-rpc;
  enable = cfg.nodes?${config.networking.hostName};
in
{
  options.ryzst.int.ci.client-rpc = {
    nodes = mkOption {
      description = "Nodes the web client is deployed to";
      type = types.attrs;
      default = { };
    };

    rpcScript = mkOption {
      type = types.package;
      default = pkgs.writeShellApplication {
        name = "laminar-rpc";
        runtimeInputs = [ config.services.laminar.package ];
        text = ''
          export LAMINAR_HOST=${config.services.laminar.rpcInterface}
          exec laminarc "$@"
        '';
      };
    };
  };

  config = mkIf enable {
    environment.systemPackages = [ ];
  };
}
