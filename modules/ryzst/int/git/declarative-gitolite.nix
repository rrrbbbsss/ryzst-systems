{ config, lib, pkgs, ... }:
# derived from:
# https://github.com/NixOS/nixpkgs/blob/797f7dc49e0bc7fab4b57c021cdf68f595e47841/nixos/modules/services/misc/gitolite.nix
with lib;
let
  cfg = config.services.declarative-gitolite;
  hooks = lib.concatMapStrings (hook: "${hook} ") cfg.commonHooks;
in
{
  options = {
    services.declarative-gitolite = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable gitolite management under the
          `gitolite` user.
        '';
      };

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/gitolite";
        description = ''
          The gitolite home directory used to store all repositories. If left as the default value
          this directory will automatically be created before the gitolite server starts, otherwise
          the sysadmin is responsible for ensuring the directory exists with appropriate ownership
          and permissions.
        '';
      };

      commonHooks = mkOption {
        type = types.listOf types.path;
        default = [ ];
        description = ''
          A list of custom git hooks that get copied to `~/.gitolite/hooks/common`.
        '';
      };

      extraGitoliteRc = mkOption {
        type = types.lines;
        default = "";
        example = literalExpression ''
          '''
            $RC{UMASK} = 0027;
            $RC{SITE_INFO} = 'This is our private repository host';
            push( @{$RC{ENABLE}}, 'Kindergarten' ); # enable the command/feature
            @{$RC{ENABLE}} = grep { $_ ne 'desc' } @{$RC{ENABLE}}; # disable the command/feature
          '''
        '';
        description = ''
          Extra configuration to append to the default `~/.gitolite.rc`.
        '';
      };

      user = mkOption {
        type = types.str;
        default = "gitolite";
        description = ''
          Gitolite user account. This is the username of the gitolite endpoint.
        '';
      };

      description = mkOption {
        type = types.str;
        default = "Gitolite user";
        description = ''
          Gitolite user account's description.
        '';
      };

      group = mkOption {
        type = types.str;
        default = "gitolite";
        description = ''
          Primary group of the Gitolite user account.
        '';
      };

      userKeys = mkOption {
        type = with types; attrsOf (listOf str);
        default = { };
        description = ''
          Keys of users.
        '';
        example = literalExpression ''
          { bob = [ "key1" "key2" "key3" ]; }
        '';
      };
    };
  };

  config = mkIf cfg.enable (
    let
      rc = pkgs.runCommand "gitolite-rc" { preferLocalBuild = true; } rcDirScript;
      rcDirScript = ''
        mkdir "$out"
        export HOME=temp-home
        mkdir -p "$HOME/.gitolite/logs" # gitolite can't run without it
        '${pkgs.gitolite}'/bin/gitolite print-default-rc >>"$out/gitolite.rc.default"
        cat <<END >>"$out/gitolite.rc"
        # This file is managed by NixOS.
        # Use services.gitolite options to control it.

        END
        cat "$out/gitolite.rc.default" >>"$out/gitolite.rc"
      '';
      conf = pkgs.writeTextFile {
        name = "gitolite-conf";
        text = ''
          repo test123
              RW+ = @all
        '';
      };
      keysJSON = pkgs.writeTextFile {
        name = "gitolite-keysJSON";
        text = builtins.toJSON cfg.userKeys;
      };
      keys = pkgs.runCommandLocal "gitolite-keyDir"
        { nativeBuildInputs = [ pkgs.jq keysJSON ]; } ''
        mkdir "$out"
        INDEX=0
        echo ${keysJSON}
        jq -r '. | keys.[]' ${keysJSON} |
           while read -r USER; do
                 jq -r --arg USER "$USER" '.[$USER].[]' ${keysJSON} |
                    while read -r KEY; do
                          printf -v PADDED_INDEX "%02d" "$INDEX"
                          mkdir -p "$out"/"$PADDED_INDEX"
                          echo "$KEY" > "$out"/"$PADDED_INDEX"/"$USER".pub
                          ((++INDEX))
                    done
           done
      '';
    in
    {
      users.users.${cfg.user} = {
        inherit (cfg) group description;
        home = cfg.dataDir;
        uid = config.ids.uids.gitolite;
        useDefaultShell = true;
      };
      users.groups.${cfg.group}.gid = config.ids.gids.gitolite;

      environment.systemPackages = [ pkgs.gitolite pkgs.git ];

      systemd.services.gitolite-init = {
        description = "Gitolite initialization";
        wantedBy = [ "multi-user.target" ];
        unitConfig.RequiresMountsFor = cfg.dataDir;

        serviceConfig = mkMerge [
          (mkIf (cfg.dataDir == "/var/lib/gitolite") {
            StateDirectory = "gitolite gitolite/.gitolite gitolite/.gitolite/logs";
            StateDirectoryMode = "0750";
          })
          {
            Type = "oneshot";
            User = cfg.user;
            Group = cfg.group;
            WorkingDirectory = "~";
            RemainAfterExit = true;
          }
        ];
        path = [
          pkgs.gitolite
          pkgs.git
          pkgs.perl
          pkgs.bash
          pkgs.diffutils
          config.programs.ssh.package
        ];
        script = ''
          if [ ! -d repositories ]; then
            gitolite setup -a dummy
            rm -r repositories/gitolite-admin.git
            rm -r repositories/testing.git
            rm .gitolite/conf/gitolite.conf
          fi

          if [ -n "${hooks}" ]; then
            cp -f ${hooks} .gitolite/hooks/common/
            chmod +x .gitolite/hooks/common/*
          fi

          ln -sf  "${rc}/gitolite.rc" .gitolite.rc
          ln -sf  "${conf}" .gitolite/conf/gitolite.conf
          ln -sfn "${keys}" .gitolite/keydir

          gitolite compile
          gitolite trigger POST_COMPILE
        '';
      };
    }
  );
}
