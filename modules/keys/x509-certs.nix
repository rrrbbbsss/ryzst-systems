{ config, lib, pkgs, ... }:
with lib;
# TODO: in hindsight,
# should work towards spiffe or something.
let
  cfg = config.keys.x509-certs;
  host = config.networking.hostName;

  x509CertType = types.submodule {
    options = {
      days = mkOption {
        type = types.int;
        example = "14";
        description = ''
          Number of days cert is valid for.
        '';
      };
      caKey = mkOption {
        type = types.str;
        default = "/persist/secrets/x509/ca.key";
        description = ''
          String to specify where to find certificate authority key.
        '';
      };
      caCrt = mkOption {
        type = types.str;
        default = "/persist/secrets/x509/ca.crt";
        description = ''
          String to specify where to find certificate authority cert.
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
    name = "gen-${name}-x509-certs";
    runtimeInputs = with pkgs; [
      coreutils-full
      openssl
    ];
    text = ''
      TMPDIR=$(mktemp -d)
      trap 'rm -rf "$TMPDIR"' EXIT

      CA_KEY="$CREDENTIALS_DIRECTORY/ca_key"
      CA_CRT="$CREDENTIALS_DIRECTORY/ca_crt"
      FILE="$TMPDIR/x509"

      # Gen Cert
      openssl req -noenc \
        -keyout "$FILE".key \
        -out "$FILE".csr \
        -newkey ec  -pkeyopt ec_paramgen_curve:prime256v1 \
        -subj "/CN=${name}.${host}.mek.ryzst.net" \
        -addext "subjectAltName=DNS:${name}.${host}.mek.ryzst.net" \
        -addext "basicConstraints = critical, CA:false" &> "$TMPDIR/trash"

      # Sign Cert
      openssl x509 -req \
        -days ${toString cfg.days} \
        -copy_extensions copyall \
        -in "$FILE".csr \
        -CA "$CA_CRT" \
        -CAkey "$CA_KEY" \
        -out "$FILE".crt &> "$TMPDIR/trash"

      #Send Key and Cert
      cat "$FILE".key <(echo) "$FILE".crt
    '';
  };

  mkPreScript = name: cfg: pkgs.writeShellApplication {
    name = "pre-x509-certs-${name}";
    runtimeInputs = [ ];
    text = ''
      cd "${cfg.certDir}"
      umask 0377
      csplit --prefix=x509-${name} \
             --suppress-matched \
             --quiet \
             "$CREDENTIALS_DIRECTORY/x509" '/^$/'
      mv x509-${name}00 x509-${name}.key
      mv x509-${name}01 x509-${name}.cert
    '';
  };
in
{
  options.keys = {
    x509-certs = mkOption {
      type = types.attrsOf x509CertType;
      default = { };
      description = ''
        Submodule for defining x509-cert generators.
      '';
    };
  };

  config = {
    systemd.sockets = foldlAttrs
      (acc: name: value: {
        "x509-certs-${name}" = {
          description = ''
            Socket for Generating x509 key and Cert for ${name}
          '';
          socketConfig = {
            ListenStream = "/run/x509-certs/${name}.socket";
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
        "x509-certs-${name}@" = {
          enable = true;
          description = ''
            Unit for Generating x509 key and Cert for ${name}
          '';
          serviceConfig = {
            Type = "simple";
            LoadCredential = [
              ("ca_key:" + value.caKey)
              ("ca_crt:" + value.caCrt)
            ];
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
          requires = [ "x509-certs-${name}.socket" ];
          serviceConfig = {
            LoadCredential = [ "x509:/run/x509-certs/${name}.socket" ];
            ExecStartPre = mkBefore [ "${getExe (mkPreScript name value)}" ];
          };
        };
      } // acc)
      { }
      cfg;
  };
}
