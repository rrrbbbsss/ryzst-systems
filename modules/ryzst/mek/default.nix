{ config, lib, ... }:
with lib;
let
  hosts = with builtins;
    let dir = ../../../hosts; in
    mapAttrs
      (n: v: { name = n; } // fromJSON (readFile (dir + "/${n}/registration.json")))
      (readDir dir);
  hostsFile = with builtins;
    toFile "${config.networking.domain}-hostsFile"
      (attrsets.foldlAttrs
        (acc: n: v: "${v.ip} ${n}.${config.networking.domain}\n${acc}") ""
        hosts);
in
{
  options.ryzst.mek = {
    hosts = mkOption {
      description = "Host instance information";
      type = types.attrs;
      default = hosts;
    };
    hostsFile = mkOption {
      description = "Hosts file of machines";
      type = types.path;
      default = hostsFile;
    };
  };
}