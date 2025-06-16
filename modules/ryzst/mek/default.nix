{ lib, self, config, ... }:
with lib;
let
  hosts = with builtins;
    let dir = ../../../hosts; in
    mapAttrs
      (n: v: {
        name = n;
        ip = self.lib.names.host.toIP n config.os.subnet;
      } // fromJSON (readFile (dir + "/${n}/registration.json")))
      (self.lib.getDirs dir);
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
