{ lib, self, ... }:
with lib;
{
  options.ryzst = {
    mek = mkOption {
      description = "Host instance information";
      type = types.attrs;
      default = self.domain.mek.hosts;
    };
  };
}
