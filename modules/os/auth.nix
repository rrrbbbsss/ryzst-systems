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
  lecture = boxedMessageFile "lecture" ''
    You'll shoot
    your eye out
  '';

  admins = lib.mapAttrs
    (n: v: {
      hashedPassword = null;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keyFiles = [ v.keys.ssh ];
    })
    config.ryzst.idm.groups.admins;

  userU2FkeyFiles =
    if builtins.isNull config.device.user
    then [ ]
    else [ config.ryzst.idm.users.${config.device.user}.keys.u2f ];

  adminsU2FkeyFiles = lib.attrsets.foldlAttrs
    (acc: n: v: acc ++ [ v.keys.u2f ])
    [ ]
    config.ryzst.idm.groups.admins;

  u2fAuthFile = pkgs.writeTextFile {
    name = "u2fAuthFile";
    text = concatStringsSep "\n"
      (map readFile (userU2FkeyFiles ++ adminsU2FkeyFiles));
  };
in
{
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
      } // admins;
    };
    security.sudo = {
      wheelNeedsPassword = false;
      execWheelOnly = true;
      extraConfig = ''
        Defaults lecture_file  = ${lecture}
      '';
    };
    security.pam = {
      u2f = {
        enable = true;
        origin = "pam://mek.ryzst.net";
        authFile = u2fAuthFile;
        cue = true;
        debug = false;
      };
      # TODO: cleanup
      services = {
        login = {
          u2fAuth = true;
          unixAuth = false;
        };
        sudo = {
          u2fAuth = true;
          unixAuth = false;
        };
        polkit-1 = {
          u2fAuth = true;
          unixAuth = false;
        };
        sshd = {
          showMotd = true;
        };
      };
    };
    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        LogLevel = "VERBOSE";
        PermitRootLogin = "prohibit-password";
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
