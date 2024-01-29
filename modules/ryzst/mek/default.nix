{ lib, pkgs, ... }:
with lib;
let
  hosts = with builtins;
    let dir = ../../../hosts; in
    mapAttrs
      (n: v: { name = n; } // fromJSON (readFile (dir + "/${n}/registration.json")))
      (pkgs.ryzst.lib.getDirs dir);
in
{
  options.ryzst = {
    mek = mkOption {
      description = "Host instance information";
      type = types.attrs;
      default = hosts;
    };
  };
}
