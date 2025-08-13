{ config, lib, ... }:
with lib;
let
  cfg = config.ryzst.int.remote-build.client;
  enable = cfg.nodes?${config.networking.hostName};
  inherit (config.ryzst.int.remote-build) server;
  knownHosts = attrsets.foldlAttrs
    (acc: n: v: { "${n}.mek.ryzst.net".publicKey = v.keys.ssh; } // acc)
    { }
    server.nodes;
  builders =
    attrsets.foldlAttrs
      (acc: n: v: [{
        hostName = "${n}.mek.ryzst.net";
        systems = [ "x86_64-linux" "aarch64-linux" ];
        protocol = "ssh";
        sshUser = "nix-rbuild";
        speedFactor = 2;
        maxJobs = 4;
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      }] ++ acc)
      [ ]
      server.nodes;
in
{
  options.ryzst.int.remote-build.client = {
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
    nix = {
      distributedBuilds = true;
      buildMachines = builders;
    };
  };
}
