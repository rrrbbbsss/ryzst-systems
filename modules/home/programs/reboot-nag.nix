{ lib, pkgs, config, osConfig, ... }:

with lib;
let
  cfg = config.services.reboot-nag;
  script = pkgs.writeShellApplication {
    name = "reboot-nag";
    runtimeInputs = with pkgs; [
      coreutils
      sway
      systemd
      bash
      procps
    ];
    text = ''
      BOOTED="$(readlink /run/booted-system/{initrd,kernel,kernel-modules})"
      BUILT="$(readlink /nix/var/nix/profiles/system/{initrd,kernel,kernel-modules})"
      UPTIME=$(cut -f 1 -d "." /proc/uptime)

      if [[ "$BOOTED" != "$BUILT" ]] || [[ "$UPTIME" -gt ${toString cfg.uptime} ]]; then
        kill "$(pidof swaynag)"
        swaynag --message "Reboot Required" \
                --layer overlay \
                --output ${osConfig.device.mirror.main} \
                --button "Reboot" "systemctl reboot"
      fi
    '';
  };
in
{
  options.services.reboot-nag = {
    enable = mkOption {
      default = true;
      example = false;
      description = "Reboot Nag";
    };
    dates = mkOption {
      type = types.str;
      default = "hourly";
      example = "hourly";
      description = lib.mdDoc ''
        How often to check for reboot.
        The format is described in
        {manpage}`systemd.time(7)`.
      '';
    };
    uptime = mkOption {
      type = types.int;
      default = 60 * 60 * 24 * 14;
      example = "1209600";
      description = lib.mdDoc ''
        Max uptime before nagging reboot.
        No immortal machines.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.user = {
      services.reboot-nag = {
        Unit.Description = "Reboot Nag";
        Service.ExecStart = ''
          ${script}/bin/reboot-nag
        '';
      };

      timers.reboot-nag = {
        Unit.Description = "Reboot Nag Timer";
        Timer = {
          Unit = "reboot-nag.service";
          OnCalendar = cfg.dates;
          Persistent = true;
        };
        Install.WantedBy = [ "timers.target" ];
      };
    };
  };
}
