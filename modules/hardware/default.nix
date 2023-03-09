{ config, pkgs, lib, ... }:
with lib;
{
  options.ryzst.hardware = {
    monitors = mkOption {
      type = types.attrsOf (types.attrsOf types.str);
      description = ''
        Monitor layout (sway-output).
      '';
    };
  };

}
