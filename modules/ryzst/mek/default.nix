{ lib, self, config, ... }:
with lib;
let
  hosts = with builtins;
    mapAttrs
      (n: v: {
        # TODO remove this?
        name = n;
        # TODO: move this
        ip = self.lib.names.host.toIP n config.os.subnet;
      } // v)
      self.domain.mek.hosts;
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
