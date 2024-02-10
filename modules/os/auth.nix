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
      users.root = {
        hashedPassword = null;
        openssh.authorizedKeys.keys = import ../../idm/groups/admins.nix;
      };
    };
    security.sudo.extraConfig = ''
      Defaults lecture_file  = ${lecture}
    '';
    security.pam = {
      u2f = {
        enable = true;
        origin = "pam://mek.ryzst.net";
        # TODO: compute file: device user + admins
        #authFile = ../../idm/users/man/pubkeys/u2f_keys;
        cue = true;
        debug = false;
      };
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
          u2fAuth = false; # TODO: ...
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
