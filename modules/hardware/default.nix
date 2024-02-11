{ lib, self, ... }:

# personalized catalog based off:
# https://github.com/NixOS/nixos-hardware
with lib;
{
  imports = [ ./common/keyboards ];

  options.device = {
    user = mkOption {
      type = types.nullOr self.outputs.lib.types.username;
      description = ''
        User assigned to device.
      '';
      default = null;
    };
    monitors = mkOption {
      type = types.attrsOf (types.attrsOf types.str);
      description = ''
        Monitor layout of deivce (sway-output).
      '';
    };
    rats = mkOption {
      type = types.attrsOf (types.attrsOf types.str);
      description = ''
        Rat setup (sway-input).
      '';
      default = { };
    };
  };
}
