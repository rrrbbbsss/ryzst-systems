{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.os.auth;
  boxedMessageFile = name: message:
    pkgs.runCommandLocal name
      { inherit (pkgs) figlet boxes; } ''
      FANCY=$(printf "${message}" \
              | $figlet/bin/figlet \
              | $boxes/bin/boxes -f $boxes/share/boxes/boxes-config)
      printf $'\e[31m%s\e[0m\n' "$FANCY" > $out
    '';
  motdFile = boxedMessageFile "motd.txt" ''
    Ryzst Systems
    ${config.networking.hostName}
  '';

  admin = {
    isNormalUser = true;
    uid = 2000;
    hashedPassword = null;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keyFiles = foldlAttrs
      (acc: n: v: acc ++ [ v.keys.ssh ])
      [ ]
      config.ryzst.idm.groups.admins;
  };

  userX509 =
    if builtins.isNull config.device.user
    then { }
    else {
      "${config.device.user}" =
        readFile config.ryzst.idm.users.${config.device.user}.keys.x509;
    };

  adminsX509 = {
    admin = foldlAttrs
      (acc: n: v: acc + "\n\n" + (readFile v.keys.x509))
      ""
      config.ryzst.idm.groups.admins;
  };

  p11x509certs = userX509 // adminsX509;
in
{
  #https://github.com/NixOS/nixpkgs/issues/16884#issuecomment-822144458
  options.security.pam.services = mkOption {
    type = types.attrsOf
      (types.submodule ({ ... }: {
        options.unixAuth = mkOption {
          apply = v: false;
        };
      }));
  };

  options.os.auth = {
    enable = mkOption {
      type = types.bool;
      default = true;
      defaultText = literalExpression true;
      description = "whether to enable default auth options";
    };
  };

  config = mkIf cfg.enable {
    users = {
      inherit motdFile;
      mutableUsers = false;
      users = {
        root = {
          hashedPassword = null;
        };
      } // { inherit admin; };
    };
    security.sudo = {
      wheelNeedsPassword = true;
      execWheelOnly = true;
      extraRules = [
        {
          users = [ "admin" ];
          commands = [ "NOPASSWD:ALL" ];
        }
      ];
      extraConfig = ''
        Defaults lecture = never
      '';
    };
    security.pam = {
      p11.enable = true;
      services.sshd.showMotd = true;
    };

    #p11
    environment.etc = foldlAttrs
      (acc: n: v: acc // { "pam_p11/${n}/eid_certificates".text = v; })
      { }
      p11x509certs;

    programs.ssh.extraConfig = ''
      Host *
        IdentityFile /persist/secrets/ssh_host_ed25519_key
    '';
    services.openssh = {
      enable = true;
      authorizedKeysInHomedir = false;
      openFirewall = true;
      settings = {
        LogLevel = "VERBOSE";
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        X11Forwarding = false;
      };
      sftpFlags = [
        "-f AUTHPRIV"
        "-l INFO"
      ];
      hostKeys = [
        {
          path = "/persist/secrets/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };
  };
}
