{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.laminar;

  globalType = types.submodule {
    options = {
      env = mkOption {
        type = with types; attrsOf str;
        default = { };
        description = ''
          Environment variables.
          Global environment for every job.
        '';
        example = {
          TEST = "123";
        };
      };
      before = mkOption {
        type = with types; nullOr path;
        default = null;
        description = ''
          Path to executable.
          Will be executed before every job's before script
        '';
      };
      after = mkOption {
        type = with types; nullOr path;
        default = null;
        description = ''
          Path to executable.
          Will be executed after every job's after script.
        '';
      };
    };
  };
  contextType = types.submodule {
    options = {
      executors = mkOption {
        type = types.ints.positive;
        description = ''
          Number of simultaneous runs that can be executed
          in the context.
        '';
        example = 1;
      };
      jobs = mkOption {
        type = with types; listOf str;
        default = [ ];
        description = ''
          List of patterns that match to jobs the context applies to.
          Patterns are glob expressions.
        '';
        example = [ "test-*" ];
      };
      env = mkOption {
        type = with types; attrsOf str;
        default = { };
        description = ''
          Environment variables.
          Applies to all jobs that are a associated with the context.
        '';
        example = {
          TEST = "123";
        };
      };
    };
  };
  jobType = types.submodule {
    options = {
      timeout = mkOption {
        type = types.ints.positive;
        description = ''
          Maximum execution time in seconds for a job.
        '';
        example = 120;
      };
      description = mkOption {
        type = types.str;
        description = ''
          Description for the job.
          Will appear on the job page in the frontend.
        '';
        example = "test";
      };
      contexts = mkOption {
        type = with types; listOf str;
        default = [ ];
        description = ''
          List of patterns that match to contexts to associate the job with.
          Patterns are glob expressions.
        '';
        example = [ "test-*" ];
      };
      env = mkOption {
        type = with types; attrsOf str;
        default = { };
        description = ''
          Environment variables.
          Applies to the job.
        '';
        example = {
          TEST = "123";
        };
      };
      init = mkOption {
        type = with types; nullOr path;
        default = null;
        description = ''
          Path to executable.
          Will be executed if workspace for job does not exist.
        '';
      };
      before = mkOption {
        type = with types; nullOr path;
        default = null;
        description = ''
          Path to executable.
          Will be executed before the job's run script.
        '';
      };
      run = mkOption {
        type = with types; nullOr path;
        description = ''
          Path to executable.
          The main script for the job.
        '';
      };
      after = mkOption {
        type = with types; nullOr path;
        default = null;
        description = ''
          Will be executed after the job's run script.
        '';
      };
    };
  };

  #TODO: write all the files
  #TODO: the init script needs to put symlinks into place
  # 
  #...
in
{
  options.services.laminar = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable laminar  CI service.
      '';
    };
    package = mkOption {
      type = types.package;
      default = pkgs.laminar;
      description = ''
        The laminar package.
      '';
    };

    webInterface = mkOption {
      type = types.str;
      default = "*:8080";
      description = ''
        The interface/port or unix socket on which
        laminard should listen for incoming connections
        to the web frontend.
      '';
    };
    rpcInterface = mkOption {
      type = types.str;
      #TODO: maybe change default to regular unix-socket?
      default = "unix-abstract:laminar";
      description = ''
        The interface/port or unix socket on which
        laminard should lsiten for incoming commands such
        as build triggers.
      '';
    };
    title = mkOption {
      type = types.str;
      default = "laminar";
      description = ''
        The page title to show ineh web frontend.
      '';
    };
    keepRundirs = mkOption {
      type = types.ints.unsigned;
      default = 0;
      description = ''
        Set to an integer defining how many rundirs to keep
        per job. The lowest-numbered ones will be deleted.
        The default is 0, meaning all run dirs will be immediately
        deleted.
      '';
    };
    archiveUrl = mkOption {
      type = types.str;
      default = "";
      description = ''
        If set, the web frontend served by laminard will use this URL
        to form linsk to artefacts archived jobs. Must be synchronized with
        web server configuration.
      '';
    };

    global = mkOption {
      type = globalType;
      default = { };
      description = ''
        Environment and before and after scripts applied
        to every job.
      '';
    };

    contexts = mkOption {
      type = types.attrsOf contextType;
      default = { };
      description = ''
        Submodule for contexts.
      '';
    };

    jobs = mkOption {
      type = types.attrsOf jobType;
      default = { };
      description = ''
        Submodule for defining jobs.

        Job Environment Variables:
        - RUN          (integer number of this run)
        - JOB          (string name of this job)
        - RESULT       (string run status: "sucess", "failed", etc.)
        - LAST_RESULT  (string previous run status)
        - WORKSPACE    (path to this job's workspace)
        - ARCHIVE      (path to this run's archive)
        - CONTEXT      (the context of this run)

        Job Additional Environment Variables:
        - global.env
        - contexts.<name>.env
        - job.<name>.env

        Job script execution order:
        - jobs.<name>.init (if workspace does not exist)
        - global.before
        - jobs.<name>.before
        - jobs.<name>.run
        - jobs.<name>.after
        - global.after
      '';
    };
    #TODO: color logs
    #TODO: customizing the webui
    #TODO: archives
  };

  config = mkIf cfg.enable (
    let
      mkEnv = name: env:
        pipe env [
          (mapAttrsToList (n: v: "${n}=${escapeShellArg v}"))
          (concatStringsSep "\n")
          (pkgs.writeText name)
        ];
      mkOptionalJobScript = phase: name: value:
        optionalAttrs (value.${phase} != null) {
          "${name}.${phase}" = value.${phase};
        };
      laminarConfig = pkgs.writeTextFile {
        name = "laminar.conf";
        text = ''
          LAMINAR_HOME=/var/lib/private/laminar
          LAMINAR_BIND_HTTP=${cfg.webInterface}
          LAMINAR_BIND_RPC=${cfg.rpcInterface}
          LAMINAR_TITLE=${cfg.title}
          LAMINAR_KEEP_RUNDIRS=${toString cfg.keepRundirs}
          LAMINAR_ARCHIVE_URL=${cfg.archiveUrl}
        '';
      };

      # cfg/env
      # cfg/before
      # cfg/after
      # cfg/contexts/CONTEXT.env
      # cfg/contexts/CONTEXT.conf
      # cfg/jobs/$JOB.env
      # cfg/jobs/$JOB.conf
      # cfg/jobs/$JOB.init
      # cfg/jobs/$JOB.before
      # cfg/jobs/$JOB.run
      # cfg/jobs/$JOB.after
      laminar-cfg = pkgs.linkFarm "laminar-cfg" ({
        env = mkEnv "global" cfg.global.env;
      }
      // (optionalAttrs (cfg.global.before != null)
        { inherit (cfg.global) before; })
      // (optionalAttrs (cfg.global.after != null)
        { inherit (cfg.global) after; })
      // {
        contexts = pkgs.linkFarm "laminar-contexts"
          (foldlAttrs
            (acc: name: value:
              {
                "${name}.env" = mkEnv "${name}.env" value.env;
                "${name}.conf" = pkgs.writeText "${name}.conf" ''
                  EXECUTORS=${toString value.executors}
                  JOBS=${concatStringsSep "," value.jobs}
                '';
              } // acc)
            { }
            cfg.contexts);
        jobs = pkgs.linkFarm "liminar-jobs"
          (foldlAttrs
            (acc: name: value:
              {
                "${name}.env" = mkEnv "${name}.env" value.env;
                "${name}.conf" = pkgs.writeText "${name}.conf" ''
                  DESCRIPTION=${value.description}
                  TIMEOUT=${toString value.timeout}
                  CONTEXTS=${concatStringsSep "," value.contexts}
                '';
                "${name}.run" = cfg.jobs.${name}.run;
              }
              // (mkOptionalJobScript "init" name value)
              // (mkOptionalJobScript "before" name value)
              // (mkOptionalJobScript "after" name value)
              // acc)
            { }
            cfg.jobs);
      });

      laminar-init = pkgs.writeShellApplication {
        name = "laminar-init";
        runtimeInputs = [ pkgs.coreutils-full ];
        text = ''
          ln -sfn "${laminar-cfg}" cfg
        '';
      };
    in
    {
      systemd.services.laminar = {
        description = "Laminar continuous integration service";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          StateDirectory = "laminar";
          WorkingDirectory = "%S/laminar";
          EnvironmentFile = laminarConfig;
          ExecStartPre = "${laminar-init}/bin/laminar-init";
          ExecStart = "${cfg.package}/bin/laminard -v";
          DynamicUser = true;
          ProtectSystem = "strict";
          NoNewPrivileges = true;
          PrivateTmp = true;
        };
      };
    }
  );
}
