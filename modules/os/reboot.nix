{ config, lib, pkgs, ... }:
let
  cfg = config.os.reboot;
in
{
  options = {
    os.reboot = {
      enable = lib.mkOption {
        default = false;
        type = lib.types.bool;
        description = ''
          Enable reboot timer.
        '';
      };
      dates = lib.mkOption {
        type = lib.types.str;
        default = "daily";
        example = "daily";
        description = ''
          How often to check to reboot.
          The format is described in
          {manpage}`systemd.time(7)`.
        '';
      };
      randomizedDelaySec = lib.mkOption {
        default = "1hr";
        type = lib.types.str;
        example = "1hr";
        description = ''
          Add a randomized delay before each reboot.
          This value must be a time span in the format specified by
          {manpage}`systemd.time(7)`
        '';
      };
      fixedRandomDelay = lib.mkOption {
        default = true;
        type = lib.types.bool;
        example = true;
        description = ''
          Make the randomized delay consistent between runs.
          This reduces the jitter between automatic reboots.
          See {option}`randomizedDelaySec` for configuring the randomized delay.
        '';
      };
      uptime = lib.mkOption {
        default = 60 * 60 * 24 * 14;
        type = lib.types.int;
        example = "1209600";
        description = ''
          Max uptime in seconds before reboot required.
          No immortal machines.
        '';
      };
    };

    persistent = lib.mkOption {
      default = true;
      type = lib.types.bool;
      example = false;
      description = ''
        Takes a boolean argument. If true, the time when the service
        unit was last triggered is stored on disk. When the timer is
        activated, the service unit is triggered immediately if it
        would have been triggered at least once during the time when
        the timer was inactive. Such triggering is nonetheless
        subject to the delay imposed by RandomizedDelaySec=. This is
        useful to catch up on missed runs of the service when the
        system was powered down.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.os-reboot = {
      description = "OS Reboot";

      restartIfChanged = false;
      unitConfig.X-StopOnRemoval = false;

      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.getExe (pkgs.writeShellApplication {
          name = "reboot";
          runtimeInputs = with pkgs; [
            coreutils-full
            config.systemd.package
          ];
          text = ''
            BOOTED=$(readlink /run/booted-system/{initrd,kernel,kernel-modules})
            BUILT=$(readlink /nix/var/nix/profiles/system/{initrd,kernel,kernel-modules})
            UPTIME=$(cut -f 1 -d " " /proc/uptime)

            if [[ "$BOOTED" != "$BUILT" ]] || [[ "$UPTIME" -gt ${toString cfg.uptime} ]]; then
              shutdown -r +1
            else
              echo "Live another day."
            fi
          '';
        });
      };

      startAt = cfg.dates;
    };
    systemd.timers.os-reboot = {
      timerConfig = {
        RandomizedDelaySec = cfg.randomizedDelaySec;
        FixedRandomDelay = cfg.fixedRandomDelay;
        Persistent = cfg.persistent;
      };
    };
  };
}
