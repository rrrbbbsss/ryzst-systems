{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.os.auth;
  motdFile = pkgs.runCommandLocal "motd.txt"
    { inherit (pkgs) figlet boxes; } ''
    printf $'\e[31m%s\e[0m\n' \
    "$(printf 'Ryzst Systems\n${config.networking.hostName}' \
    | $figlet/bin/figlet \
    | $boxes/bin/boxes -f $boxes/share/boxes/boxes-config)" \
    > $out
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
    security.pam = {
      u2f = {
        enable = true;
        origin = "pam://mek.ryzst.net";
        authFile = ../../idm/users/rrrbbbsss/pubkeys/u2f_keys;
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
          u2fAuth = false; # todo...
          showMotd = true;
        };
      };
    };
    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
      hostKeys = [
        {
          path = "/persist/secrets/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };
  };
}
