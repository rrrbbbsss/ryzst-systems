# derived from:
# https://github.com/NixOS/nixpkgs/blob/9c6b49aeac36e2ed73a8c472f1546f6d9cf1addc/nixos/modules/tasks/auto-upgrade.nix
{ config, lib, pkgs, ... }:
let cfg = config.os.upgrade;

in {

  options = {

    os.upgrade = {

      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to periodically upgrade os to the latest version.
        '';
      };

      repo = lib.mkOption {
        type = lib.types.str;
        default = config.os.flake;
        example = "git+ssh://git@example.com/repo";
        description = ''
          The repo URI of the NixOS configuration to build.
        '';
      };

      dates = lib.mkOption {
        type = lib.types.str;
        default = "*:0/10";
        example = "*:0/10";
        description = ''
          How often or when upgrade occurs.

          The format is described in
          {manpage}`systemd.time(7)`.
        '';
      };

      randomizedDelaySec = lib.mkOption {
        default = "10min";
        type = lib.types.str;
        example = "10min";
        description = ''
          Add a randomized delay before each automatic upgrade.
          The delay will be chosen between zero and this value.
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
          This reduces the jitter between automatic upgrades.
          See {option}`randomizedDelaySec` for configuring the randomized delay.
        '';
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

  };

  config = lib.mkIf cfg.enable {

    systemd.services.os-upgrade = {
      description = "OS Upgrade";

      restartIfChanged = false;
      unitConfig.X-StopOnRemoval = false;

      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.getExe (pkgs.writeShellApplication {
          name = "update";
          runtimeInputs = with pkgs; [
            git
            coreutils-full
            nix
            jq
            openssh
          ];
          text = ''
            TMPDIR=$(mktemp -d)
            trap 'rm -rf "$TMPDIR"' EXIT

            # Get cached store-path from json file
            git clone --depth=1 --branch="hosts" "${cfg.repo}" "$TMPDIR"
            STOREPATH=$(jq -er --arg h "$(cat /etc/hostname)" '.hosts.[$h]' "$TMPDIR"/hosts.json)

            # Update TODO: rethink this check
            CURRENT=$(readlink /run/current-system)
            if [[ "$CURRENT" != "$STOREPATH" ]]; then
              # download store-path
              nix-store --add-root "$TMPDIR/result" --realise "$STOREPATH"
              # update profile
              nix-env -p /nix/var/nix/profiles/system --set "$STOREPATH"
              # activate boot
              "$STOREPATH"/bin/switch-to-configuration boot

              BOOTED=$(readlink /run/booted-system/{initrd,kernel,kernel-modules})
              BUILT=$(readlink /nix/var/nix/profiles/system/{initrd,kernel,kernel-modules})
              if [[ "$BOOTED" = "$BUILT" ]]; then
                # TODO: pay attention to soft-reboot 
                # https://github.com/NixOS/nixpkgs/pull/309911
                "$STOREPATH"/bin/switch-to-configuration switch
              fi
            else
              echo "Nothing to do."
            fi
          '';
        });
      };

      startAt = cfg.dates;

      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
    };

    systemd.timers.os-upgrade = {
      timerConfig = {
        RandomizedDelaySec = cfg.randomizedDelaySec;
        FixedRandomDelay = cfg.fixedRandomDelay;
        Persistent = cfg.persistent;
      };
    };
  };
}
