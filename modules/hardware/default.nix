{ lib, ... }:

# personalized catalog based off:
# https://github.com/NixOS/nixos-hardware
with lib;
{
  imports = [ ./common/keyboards ];

  options.device = {
    user = mkOption {
      type = types.str;
      description = ''
        User assigned to device.
      '';
    };
    monitors = mkOption {
      type = types.attrsOf (types.attrsOf types.str);
      description = ''
        Monitor layout of deivce (sway-output).
      '';
    };
  };
}
