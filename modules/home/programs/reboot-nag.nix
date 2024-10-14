{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.services.reboot-nag;
  script = pkgs.writeShellApplication {
    name = "reboot-nag";
    runtimeInputs = [ pkgs.coreutils pkgs.sway pkgs.systemd pkgs.bash ];
    text = ''
      booted="$(readlink /run/booted-system/{initrd,kernel,kernel-modules})"
      built="$(readlink /nix/var/nix/profiles/system/{initrd,kernel,kernel-modules})"

      if [ "''${booted}" != "''${built}" ]; then
        swaynag --message "Reboot Required" \
                --layer overlay \
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
