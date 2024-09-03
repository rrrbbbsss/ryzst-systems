{ config, lib, pkgs, ... }:
# derived from:
# https://github.com/NixOS/nixpkgs/blob/797f7dc49e0bc7fab4b57c021cdf68f595e47841/nixos/modules/services/misc/gitolite.nix
with lib;
let
  cfg = config.services.declarative-gitolite;
  hooks = lib.concatMapStrings (hook: "${hook} ") cfg.commonHooks;
  rcType = types.submodule {
    options = {
      UMASK = mkOption {
        type = types.str;
        default = "0077";
        description = ''
          The default umask for repositories.
        '';
        example = "0077";
      };
      GIT_CONFIG_KEYS = mkOption {
        type = with types; listOf str;
        default = [ ];
        description = ''
          List of regexes for allowed git-config keys.
        '';
        example = literalExpression ''
          [ "core\.logAllRefUpdates" "core\..*compression" ]
        '';
      };

      LOG_EXTRA = mkOption {
        type = with types; nullOr bool;
        default = true;
        description = ''
          Extra detail in logfile
        '';
      };
      LOG_DEST = mkOption {
        type = with types; nullOr (listOf (enum [ "syslog" "normal" "repo-log" ]));
        default = null;
        description = ''
          List of logging destinations.
          Empty List is normal (default) logging.
        '';
      };
      LOG_FACILITY = mkOption {
        type = with types; nullOr str;
        default = null;
        description = ''
          syslog 'facility': defaults to 'local0'
        '';
        example = literalExpression ''
          "local4"
        '';
      };

      # avoid caching:
      # CACHE
      # CACHE_TTL

      ROLES = mkOption {
        type = with types; attrsOf bool;
        default = {
          READERS = true;
          WRITERS = true;
        };
        description = ''
          Attrset of role names for wildcard repos.
        '';
      };
      OWNER_ROLENAME = mkOption {
        type = with types; nullOr str;
        default = null;
        description = ''
          Name for Owner role for assigning permissions.
        '';
        example = ''
          "OWNERS"
        '';
      };

      SITE_INFO = mkOption {
        type = with types; nullOr str;
        default = null;
        description = ''
          Additional info that the 'info' command prints.
        '';
        example = literalExpression ''
          "Please see https://example.com/gitolite for more help"
        '';
      };

      # for CpuTime feature:
      # DISPLAY_CPU_TIME
      # CPU_TIME_WARN_LIMIT

      # for Mirroring feature:
      # HOSTNAME

      LOCAL_CODE = mkOption {
        type = with types; nullOr path;
        default = null;
        description = ''
          Location for site-local gitolite code.
        '';
      };

      ENABLE = mkOption {
        type = with types; listOf str;
        default = [
          #COMMANDS
          "help"
          "desc"
          "info"
          "perms"
          "writable"
          #FEATURES
          "ssh-authkeys"
          "git-config"
          "daemon"
          "gitweb"
        ];
      };
      description = ''
        List of Commands and Features to enable.
        See https://github.com/sitaramc/gitolite/blob/a546e5e8bdbb7069b995ca95fd20556157b0b439/src/lib/Gitolite/Rc.pm#L574
        for a list of builtin commands and features.
      '';

      #for triggers to run after builtin triggers:
      #NON_CORE
    };
  };
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

      rc = mkOption {
        type = rcType;
        description = ''
          Submodule to declare the RC file.
        '';
        default = { };
      };
    };
  };

  config = mkIf cfg.enable (
    let
      format = key: fun:
        let val = cfg.rc.${key};
        in
        if (val == null)
        then "#${key}" else
          "${key} => ${fun val},"
      ;
      # gross but good enough
      rc = pkgs.writeTextFile {
        name = "gitolite-rc";
        text = ''
          %RC = (
              ${format "UMASK"
                (v: v)}
              ${format "GIT_CONFIG_KEYS"
                (v: "'${builtins.concatStringsSep " " v}'")}

              ${format "LOG_EXTRA"
                (v: "1")}
              ${format "LOG_DEST"
                (v: "'${builtins.concatStringsSep "," v}'")}
              ${format "LOG_FACILITY"
                (v: "'${v}'")}

              ${format "ROLES"
                (let
                  ownerVal = cfg.rc.OWNER_ROLENAME;
                  owner = if ownerVal != null then { ${ownerVal} = true; } else { };
                  in
                    v: "{\n" +
                       (foldlAttrs (acc: n: _: "      ${n} => 1,\n" + acc) "" (v // owner)) +
                       "    }")}
              ${format "OWNER_ROLENAME"
                (v: "'${v}'")}

              ${format "SITE_INFO"
                (v: "'${v}'")}
              ${format "LOCAL_CODE"
                (v: "'${v}'")}

              ${format "ENABLE"
                (v: "[\n" +
                    (fold (x: acc: "      '${x}',\n" + acc) "" v) +
                    "    ]")}
          );
          1;
        '';
      };
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

          ln -sf  "${rc}" .gitolite.rc
          ln -sf  "${conf}" .gitolite/conf/gitolite.conf
          ln -sfn "${keys}" .gitolite/keydir

          gitolite compile
          gitolite trigger POST_COMPILE
        '';
      };
    }
  );
}
