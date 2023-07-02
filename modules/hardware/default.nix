{ lib, ... }:

# personalized catalog based off:
# https://github.com/NixOS/nixos-hardware
with lib;
{
  options.device = {
    monitors = mkOption {
      type = types.attrsOf (types.attrsOf types.str);
      description = ''
        Monitor layout of deivce (sway-output).
      '';
    };
  };
}
