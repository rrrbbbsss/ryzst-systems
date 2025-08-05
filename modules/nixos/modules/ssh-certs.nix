{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.keys.ssh-certs;

  sshCertType = types.submodule {
    options = {
      validInterval = mkOption {
        type = types.str;
        example = "+5m";
        description = ''
          Valid interval for cert.
          See `ssh-keygen(1)` for validity_interval format.
        '';
      };
      forceCommand = mkOption {
        type = types.str;
        description = ''
          The command to force when the certificate is used
          for authentication.
        '';
      };
      sourceAddress = mkOption {
        type = types.str;
        description = ''
          CIDR for the source address the certificate can be used from.
        '';
      };
      extraPrincipals = mkOption {
        type = with types; listOf str;
        description = ''
          List of extra principals to use for certificate.
        '';
      };
      extensions = mkOption {
        type = with types; listOf (enum [
          "permit-agent-forwarding"
          "permit-port-forwarding"
          "permit-pty"
          "permit-user-rc"
          "permit-X11-forwarding"
        ]);
        default = [ ];
        description = ''
          List of extensions to allow.
        '';
      };

      caKey = mkOption {
        type = types.str;
        default = "/persist/secrets/ssh_host_ed25519_key";
        description = ''
          String to specify where to find certificate authority key.
        '';
      };
      certDir = mkOption {
        type = types.str;
        default = "$RUNTIME_DIRECTORY";
        description = ''
          Directory to put the private key and cert files.
          for Service.
        '';
      };
      systemdServiceName = mkOption {
        type = types.str;
        example = "someservice";
        description = ''
          The name of a systemd service that
          will have access to the private key and cert files.
        '';
      };
    };
  };

  mkGenScript = name: cfg: pkgs.writeShellApplication {
    name = "gen-${name}-ssh-certs";
    runtimeInputs = with pkgs; [
      coreutils-full
      openssh
    ];
    text = ''
      TMPDIR=$(mktemp -d)
      trap 'rm -rf "$TMPDIR"' EXIT

      CA_KEY="$CREDENTIALS_DIRECTORY/ca_key"
      ID=${escapeShellArg name}
      FILE="$TMPDIR/$ID"

      #Gen Key
      ssh-keygen -q -N "" -t ed25519 -f "$FILE"

      #SignCert
      ssh-keygen -s "$CA_KEY" \
                 -I "$ID" \
                 -z "$(date +%s)" \
                 -V ${escapeShellArg cfg.validInterval} \
                 -n ${escapeShellArg (concatStringsSep "," ([name] ++ cfg.extraPrincipals))} \
                 -O clear ${concatStringsSep "-O " cfg.extensions} \
                 -O source-address=${escapeShellArg cfg.sourceAddress} \
                 -O force-command=${builtins.unsafeDiscardStringContext (escapeShellArg cfg.forceCommand)} \
                 -q "$FILE"

      #Send Key and Cert
      cat "$FILE" <(echo) "$FILE-cert.pub"
    '';
  };

  mkPreScript = name: cfg: pkgs.writeShellApplication {
    name = "pre-ssh-certs-${name}";
    runtimeInputs = [ ];
    text = ''
      cd "${cfg.certDir}"
      umask 0377
      csplit --prefix=ssh \
             --suppress-matched \
             --quiet \
             "$CREDENTIALS_DIRECTORY/ssh" '/^$/'
      mv ssh00 ssh.key
      mv ssh01 ssh.cert
    '';
  };


in
{
  options.keys = {
    ssh-certs = mkOption {
      type = types.attrsOf sshCertType;
      default = { };
      description = ''
        Submodule for defining ssh-cert generators.
      '';
    };
  };

  config = {
    systemd.sockets = foldlAttrs
      (acc: name: value: {
        "ssh-certs-${name}" = {
          description = ''
            Socket for Generating SSH key and Cert for ${name}
          '';
          socketConfig = {
            ListenStream = "/run/ssh-certs/${name}.socket";
            SocketUser = "root";
            SocketGroup = "root";
            SocketMode = "0600";
            Accept = true;
          };
          wantedBy = [ "sockets.target" ];
        };
      } // acc)
      { }
      cfg;

    systemd.services = foldlAttrs
      (acc: name: value: {
        "ssh-certs-${name}@" = {
          enable = true;
          description = ''
            Unit for Generating SSH key and Cert for ${name}
          '';
          serviceConfig = {
            Type = "simple";
            LoadCredential = [ ("ca_key:" + value.caKey) ];
            ExecStart = "${getExe (mkGenScript name value)}";
            StandardInput = "socket";
            #TODO: lock down service more
            DynamicUser = true;
            NoNewPrivileges = true;
            ProtectSystem = "full";
          };
        };
        # For services that need it:
        "${value.systemdServiceName}" = {
          requires = [ "ssh-certs-${name}.socket" ];
          serviceConfig = {
            RuntimeDirectory = [ name ];
            LoadCredential = [ "ssh:/run/ssh-certs/${name}.socket" ];
            ExecStartPre = [ "${getExe (mkPreScript name value)}" ];
          };
        };
      } // acc)
      { }
      cfg;
  };
}
