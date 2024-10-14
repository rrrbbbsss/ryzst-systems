{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.device.keyboard;
in
{
  options.device.keyboard = {
    remap.enable = mkEnableOption "Remap keys";
    name = mkOption {
      type = types.str;
      description = "Name of keyboard";
    };
    path = mkOption {
      type = types.str;
      description = "Path to device";
    };
    layout = mkOption {
      type = types.path;
      description = "Config of layout of keyboard";
      default = ./kanata.kbd;
    };
  };
  config = mkIf cfg.remap.enable {
    services.kanata = {
      enable = true;
      keyboards = {
        ${cfg.name} = {
          devices = [ cfg.path ];
          port = null;
          config = builtins.readFile cfg.layout;
        };
      };
    };

    # TODO: wait for proper fix
    # https://github.com/NixOS/nixpkgs/issues/317282
    systemd.services."kanata-${cfg.name}" = {
      serviceConfig.ExecStartPre = [ "${pkgs.coreutils-full}/bin/sleep 5" ];
    };
  };
}

