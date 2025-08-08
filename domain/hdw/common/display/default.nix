{ lib, ... }:
with lib;
{
  options.device = {
    # TODO: do this better
    mirror = mkOption {
      type = types.attrsOf types.str;
      description = ''
        Monitor mirroring
      '';
      default = {
        main = "null";
        secondary = "null";
      };
    };
    monitors = mkOption {
      type = types.attrsOf (types.attrsOf types.str);
      description = ''
        Monitor layout of deivce (sway-output).
      '';
    };
  };
}
