{ lib, pkgs, config, ... }:
#for now: explicitly delete home-manager generations for gc
#https://github.com/nix-community/home-manager/issues/4204
with lib;
let
  cfg = config.home-gc;
in
{
  options.home-gc = {
    enable = mkOption {
      default = true;
      example = false;
      description = "home-manager generation gc";
    };

    dates = mkOption {
      type = types.str;
      default = "weekly";
      example = "weekly";
      description = lib.mdDoc ''
        How often or when garbage collection is performed.
        The format is described in
        {manpage}`systemd.time(7)`.
      '';
    };
    expire = mkOption {
      type = types.int;
      default = 21;
      example = 21;
      description = lib.mdDoc ''
        The number of days to keep a home-manager generation until it expires
        and is deleted.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.user = {
      services.home-gc = {
        Unit.Description = "Home Manager Garbage Collector";
        Service.ExecStart = ''
          ${pkgs.home-manager}/bin/home-manager expire-generations "-${toString cfg.expire} days"
        '';
      };

      timers.home-gc = {
        Unit.Description = "Home Manager Garbage Collector Timer";
        Timer = {
          Unit = "home-gc.service";
          OnCalendar = cfg.dates;
          Persistent = true;
        };
        Install.WantedBy = [ "timers.target" ];
      };
    };
  };
}
