{ config, lib, pkgs, ... }:
let
  cfg = config.os.misc-gc;
in
{
  options = {
    os.misc-gc = {
      enable = lib.mkOption {
        default = false;
        type = lib.types.bool;
        description = ''
          Enable misc-gc timer.
        '';
      };
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.ryzst.root-cleaner;
        description = ''
          Package to use.
        '';
      };
      dates = lib.mkOption {
        type = lib.types.str;
        default = "weekly";
        example = "weekly";
        description = ''
          How often to misc-gc.
          The format is described in
          {manpage}`systemd.time(7)`.
        '';
      };
      expire = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 21;
        example = 21;
        description = ''
          The number of days to keep misc roots until they expire.
        '';
      };
      persistent = lib.mkOption {
        default = true;
        type = lib.types.bool;
        example = false;
        description = ''
          Trigger service if date missed.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.misc-gc = {
      description = "Clean up misc roots.";

      restartIfChanged = false;
      unitConfig.X-StopOnRemoval = false;

      serviceConfig = {
        Type = "oneshot";
        ExecStart = ''
          ${lib.getExe cfg.package} ${toString cfg.expire}
        '';
      };

      startAt = cfg.dates;
    };
    systemd.timers.misc-gc = {
      timerConfig = {
        Persistent = cfg.persistent;
      };
    };
  };
}
