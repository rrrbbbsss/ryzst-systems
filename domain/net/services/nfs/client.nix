{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.ryzst.int.nfs.client;
  enable = cfg.nodes?${config.networking.hostName};
in
{
  options.ryzst.int.nfs.client = {
    nodes = mkOption {
      description = "Nodes the client is deployed to";
      type = types.attrs;
      default = { };
    };
  };

  config = mkIf enable
    {
      systemd.mounts = [{
        type = "nfs";
        mountConfig = {
          Options = "noatime";
        };
        what = "nfs.int.ryzst.net:/dump";
        where = "/nfs";
      }];
      systemd.automounts = [{
        wantedBy = [ "multi-user.target" ];
        automountConfig = {
          TimeoutIdleSec = "600";
        };
        where = "/nfs";
      }];
      environment.systemPackages = with pkgs; [
        nfs-utils
      ];
    };
}
