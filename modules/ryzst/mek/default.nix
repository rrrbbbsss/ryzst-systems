{ lib, pkgs, self, ... }:
with lib;
let
  hosts = with builtins;
    let dir = ../../../hosts; in
    mapAttrs
      (n: v: {
        name = n;
        ip = self.outputs.lib.names.host.toIP n;
      } // fromJSON (readFile (dir + "/${n}/registration.json")))
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
