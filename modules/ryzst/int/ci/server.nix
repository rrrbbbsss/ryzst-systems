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

    networking.firewall.extraCommands = ''
      ${pkgs.nftables}/bin/nft add rule ip6 filter nixos-fw iifname "wg0" counter ip6 saddr { ${client-webIps} } tcp dport ${builtins.toString cfg.web-port} jump nixos-fw-accept

      ${pkgs.nftables}/bin/nft add rule ip6 filter nixos-fw iifname "wg0" counter ip6 saddr { ${client-rpcIps} } tcp dport ${builtins.toString cfg.rpc-port} jump nixos-fw-accept
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
          timeout = 60 * 60 * 4;
          description = "this is temp";
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

              printf "Building Paths:\n"
              nix-eval-jobs \
                  --workers 4 \
                  --gc-roots-dir "$TMPDIR" \
                  --flake "$FLAKE?ref=main&rev=$COMMIT"#hosts \
              	| tee -a eval.json \
              	| jq -r --unbuffered '.drvPath' \
              	| parallel --halt-on-error 2 nix-build {}


              # JSON
              # shellcheck disable=SC2016
              FILTER='{commit: $COMMIT, hosts:
                               (reduce .[] as $i ({}; . + ($i | { (.attr): .outputs.out})))}'
              JSON=$(jq -s "$FILTER" --arg COMMIT "$COMMIT" eval.json)
              printf "JSON:\n%s\n" "$JSON"

              # Push JSON
              mkdir "$REPO"
              git clone --depth=1 --branch="$BRANCH" "$FLAKE" "$REPO"
              cd "$REPO"
              echo "$JSON" > "hosts.json"
              git config user.name  "$GIT_NAME"
              git config user.email "$GIT_EMAIL"
              # TODO: Don't be negligent
              # git config user.signingKey "$GPG_KEY"
              git commit -m "cache: $COMMIT" hosts.json || true
              git pull --rebase --autostash
              git push
            '';
          });
        };
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
