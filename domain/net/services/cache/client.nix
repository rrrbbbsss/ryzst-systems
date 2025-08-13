{ config, lib, ... }:
with lib;
let
  cfg = config.ryzst.int.cache.client;
  enable = cfg.nodes?${config.networking.hostName};
  inherit (config.ryzst.int.cache) server;
  knownHosts = attrsets.foldlAttrs
    (acc: n: v: { "${n}.mek.ryzst.net".publicKey = v.keys.ssh; } // acc)
    { }
    server.nodes;
  trusted-public-keys =
    attrsets.foldlAttrs
      (acc: n: v: [ v.keys.nix ] ++ acc)
      [ ]
      server.nodes;
  substituters =
    attrsets.foldlAttrs
      (acc: n: v: [ "ssh://nix-ssh@${n}.mek.ryzst.net?priority=10" ] ++ acc)
      [ ]
      server.nodes;
in
{
  options.ryzst.int.cache.client = {
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
    nix.settings = {
      inherit
        trusted-public-keys
        substituters;
    };
  };
}
