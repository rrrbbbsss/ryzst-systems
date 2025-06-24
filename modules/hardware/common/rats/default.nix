{ lib, ... }:
with lib;
{
  options.device = {
    rats = mkOption {
      type = types.attrsOf (types.attrsOf types.str);
      description = ''
        Rat setup (sway-input).
      '';
      default = { };
    };
  };
}
