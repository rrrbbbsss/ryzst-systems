{ config, lib, ... }:
with lib;
let
  cfg = config.ryzst.int.git.client;
  enable = cfg.nodes?${config.networking.hostName};
  inherit (config.ryzst.int.git) server;
  knownHosts = attrsets.foldlAttrs
    (acc: n: v: { "git.int.ryzst.net".publicKey = v.keys.ssh; } // acc)
    { }
    server.nodes;
in
{
  options.ryzst.int.git.client = {
    nodes = mkOption {
      description = "Nodes the client is deployed to";
      type = types.attrs;
      default = { };
    };
  };

  config = mkIf enable {
    programs.ssh = {
      inherit knownHosts;
    };

    environment.systemPackages = mkIf server.enableGitAnnex
      [ pkgs.git-annex ];
  };
}
