{ config, pkgs, lib, ... }:
let
  cfg = config.os.boxed-motd;

  boxedMessageFile = message:
    pkgs.stdenvNoCC.mkDerivation {
      name = "motd.txt";
      dontUnpack = true;
      nativeBuildInputs = with pkgs; [ figlet boxes ];
      installPhase = ''
        FANCY=$(printf "${message}" \
                | figlet \
                | boxes -f ${pkgs.boxes}/share/boxes/boxes-config)
        printf $'\e[31m%s\e[0m\n' "$FANCY" > $out
      '';
    };
in
{
  options = {
    os.boxed-motd = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Enable boxed-motd.
        '';
      };
      message = lib.mkOption {
        type = lib.types.str;
        default = ''
          ${config.networking.hostName}
        '';
        description = ''
          Message for boxed-motd.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.motdFile = boxedMessageFile cfg.message;
  };
}

