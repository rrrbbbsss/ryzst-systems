{ config, lib, pkgs, ... }:
with lib;
let
  mkAuthorizedKey = key: ip:
    (concatStringsSep "," [
      "cert-authority"
      ''principals="hello"''
      ''command="${config.ryzst.int.ci.client-rpc.rpcScript}/bin/laminar-rpc queue hello"''
      "restrict"
      "no-port-forwarding"
      "no-X11-forwarding"
      "no-agent-forwarding"
      "no-pty"
      "no-user-rc"
      ''from="${ip}"''
    ]) + " ${key}";
  cfg = config.ryzst.int.ci.server;
  enable = cfg.nodes?${config.networking.hostName};
  client-webIps = attrsets.foldlAttrs
    (acc: n: v: "${v.ip}, ${acc}")
    ""
    config.ryzst.int.ci.client-web.nodes;
  client-rpcIps = attrsets.foldlAttrs
    (acc: n: v: "${v.ip}, ${acc}")
    ""
    config.ryzst.int.ci.client-rpc.nodes;
  client-rpcKeys =
    attrsets.foldlAttrs
      (acc: n: v: [ (mkAuthorizedKey v.keys.ssh v.ip) ] ++ acc) [ ]
      config.ryzst.int.ci.client-rpc.nodes;
  # TODO: generate this properly
  client-certs = config.ryzst.idm.users.man.keys.x509;
in
{
  options.ryzst.int.ci.server = {
    enable = mkEnableOption "Internal ci service";
    nodes = mkOption {
      description = "Nodes the service is deployed to";
      type = types.attrs;
      default = { };
    };
    web-port = mkOption {
      description = "The port for the web service to listen on";
      type = types.int;
      default = 8080;
    };
    rpc-port = mkOption {
      description = "The port for the rpc service to listen on";
      type = types.int;
      default = 22;
    };
  };
  config = mkIf enable {

    networking.firewall.extraInputRules = ''
      iifname "wg0" counter ip6 saddr { ${client-webIps} } tcp dport ${builtins.toString cfg.web-port} accept
      iifname "wg0" counter ip6 saddr { ${client-rpcIps} } tcp dport ${builtins.toString cfg.rpc-port} accept
    '';

    # TODO: will have redo cert gen so certs can expire quickly.
    keys.ssh-certs.laminar = {
      validInterval = "+3w";
      forceCommand = "${pkgs.gitolite}/bin/gitolite-shell laminar";
      sourceAddress = cfg.nodes.${config.networking.hostName}.ip;
      extraPrincipals = [ ];
      extensions = [ ];
      systemdServiceName = "laminar";
    };

    keys.x509-certs.ci = {
      days = 21;
      systemdServiceName = "nginx";
    };
    services.nginx = {
      enable = true;
      sslProtocols = "TLSv1.3";
      virtualHosts."ci.${config.networking.hostName}.mek.ryzst.net" = {
        listen = [
          {
            addr = "[${cfg.nodes.${config.networking.hostName}.ip}]";
            port = cfg.web-port;
            ssl = true;
          }
        ];
        onlySSL = true;
        sslCertificate = "/run/nginx/x509-ci.cert";
        sslCertificateKey = "/run/nginx/x509-ci.key";
        extraConfig = ''
          ssl_client_certificate ${client-certs};
          ssl_verify_depth 1;
          ssl_verify_client on;
        '';
        # TODO: unix sockets
        locations = {
          "/" = { proxyPass = "http://127.0.0.1:10000"; };
          "= /style.css" = {
            alias = ./style.css;
          };
        };
      };
    };

    services.laminar = {
      enable = true;
      title = "Laminar";
      #TODO: unix socket
      webInterface = "127.0.0.1:10000";
      #rpcInterface = "unix:/run/laminar/rpc.sock";
      contexts = {
        hosts-job = {
          executors = 1;
          jobs = [ "hosts-job" ];
        };
      };
      jobs = {
        hosts-job = {
          timeout = 60 * 60 * 8;
          description = "blah.";
          run = getExe (pkgs.writeShellApplication {
            name = "hosts-job";
            runtimeInputs = with pkgs; [
              coreutils-full
              nix-eval-jobs
              git
              jq
              parallel
              openssh
              nix
            ];
            text = ''
              TMPDIR=$(mktemp -d)
              trap 'rm -rf "$TMPDIR"' EXIT
              cd "$TMPDIR"

              export GIT_SSH_COMMAND="ssh -i $RUNTIME_DIRECTORY/ssh.key -o CertificateFile=$RUNTIME_DIRECTORY/ssh.cert"

              FLAKE="git+ssh://git@git.int.ryzst.net/domain"
              BRANCH="hosts"
              GIT_NAME="laminar"
              # TODO: don't hardcode
              GIT_EMAIL="laminar@tin-jet.mek.ryzst.net"
              REPO="$TMPDIR/repo"
              #GPG_KEY="TODO"
              ROOT_DIR=/var/lib/laminar/roots/hosts-job

              # TODO: validate repo signatures
              # could use 'guix git authenticate'
              # as a starting point...

              printf "Commit:\n%s\n\n" "$COMMIT"

              printf "Building Paths:\n"
              # shellcheck disable=SC2016
              nix-eval-jobs \
                  --workers 4 \
                  --gc-roots-dir "$TMPDIR" \
                  --flake "$FLAKE?dir=/sub&ref=main&rev=$COMMIT"#hosts \
              	| tee -a eval.json \
              	| jq -r --unbuffered '.drvPath' \
              	| parallel --halt-on-error 2 'nix-build {} --out-link "$(basename {})"'

              # JSON
              # shellcheck disable=SC2016
              FILTER='{commit: $COMMIT, hosts:
                               (reduce .[] as $i ({}; . + ($i | { (.attr): .outputs.out})))}'
              JSON=$(jq -s "$FILTER" --arg COMMIT "$COMMIT" eval.json)
              printf "\nJSON:\n%s\n\n" "$JSON"

              # Push to cache
              # (currently cheesing it since on same host)
              printf "Register gc roots:\n"
              jq -r '.hosts | to_entries[] | "\(.key) \(.value)"' <<<"$JSON" \
                | parallel --colsep ' ' \
                  "nix-store --add-root $ROOT_DIR/$COMMIT-hosts-{1} --realise {2}"
              printf "\n"

              # Push JSON
              printf "Push to git:\n"
              mkdir "$REPO"
              git clone --depth=1 --branch="$BRANCH" "$FLAKE" "$REPO"
              cd "$REPO"
              echo "$JSON" > "hosts.json"
              git config user.name  "$GIT_NAME"
              git config user.email "$GIT_EMAIL"
              # TODO: Don't be negligent
              # (look into sigstore for ephemeral x509)
              # git config user.signingKey "$GPG_KEY"
              git commit -m "cache: $COMMIT" hosts.json || true
              git pull --rebase --autostash
              git push
            '';
          });
        };
      };
    };

    #gc-timer
    systemd.services.hosts-job-gc = {
      description = "Clean up hosts-job roots.";
      restartIfChanged = false;
      unitConfig.X-StopOnRemoval = false;
      serviceConfig = {
        Type = "oneshot";
        ExecStart = getExe (pkgs.writeShellApplication {
          name = "hosts-job-gc";
          runtimeInputs = with pkgs; [
            coreutils-full
            findutils
            gawk
          ];
          text = ''
            shopt -s nullglob globstar

            ROOT_DIR=/var/lib/laminar/roots/hosts-job
            CURRENT=$(date '+%s')
            SECONDS=$((21 * 86400))
            EXPIRED=$((CURRENT - SECONDS))

            stat --format='%Y %N' "$ROOT_DIR"/* \
              | sort --reverse \
              | awk -v X="$EXPIRED" '(NR > 10) && ($1 < X) { print $2 }' \
              | xargs -I '{}' unlink '{}'
          '';
        });
      };
      startAt = "weekly";
    };
    systemd.timers.hosts-job-gc = {
      timerConfig = {
        Persistent = true;
      };
    };


    #rpc
    services.openssh.enable = true;
    users.users.laminar.openssh.authorizedKeys.keys = client-rpcKeys;
    services.openssh.extraConfig = ''
      Match User laminar
        AllowAgentForwarding no
        AllowTcpForwarding no
        PermitTTY no
        PermitTunnel no
        X11Forwarding no
      Match All
    '';
  };
}
