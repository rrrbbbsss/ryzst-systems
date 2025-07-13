{ config, lib, pkgs, ... }:
let
  cfg = config.os.misc-gc;

  regex = lib.fold
    (x: acc:
      let
        rest = if acc == "" then "" else "|${acc}";
      in
      "(${lib.escape ["\\"] (lib.escape [ "/" "." ] x)})${rest}"
    )
    ""
    cfg.ignoreDirs;
  script = pkgs.writeShellApplication
    {
      name = "root-cleaner";
      runtimeInputs = with pkgs; [
        coreutils-full
        findutils
        gawk
      ];
      text = ''
        shopt -s nullglob globstar

        DAYS=${toString cfg.expire}

        ROOT_DIR=${cfg.gcroots}

        REGEX='^\47(${regex})'

        CURRENT=$(date '+%s')
        SECONDS=$((DAYS * 86400))
        EXPIRED=$((CURRENT - SECONDS))

        # shellcheck disable=SC2016
        SCRIPT='($4 < X) && ($3 !~ R) { print $1 }'

        stat --format='%N %Y' "$ROOT_DIR"/* \
          | awk -v X="$EXPIRED" -v R="$REGEX" "$SCRIPT" \
          | xargs -I '{}' unlink '{}'
      '';
    };
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
        default = script;
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
      gcroots = lib.mkOption {
        type = lib.types.str;
        default = "/nix/var/nix/gcroots/auto";
        description = ''
          Directory of gcroots.
        '';
      };
      ignoreDirs = lib.mkOption {
        type = with lib.types; listOf str;
        example = [
          "/path/to/a/dir/"
        ];
        description = ''
          Directories to ignore from cleaning.
          "/nix/var/nix/profiles/" is always added.
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
    os.misc-gc.ignoreDirs = [ "/nix/var/nix/profiles/" ];

    systemd.services.misc-gc = {
      description = "Clean up misc roots.";

      restartIfChanged = false;
      unitConfig.X-StopOnRemoval = false;

      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.getExe script;
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
