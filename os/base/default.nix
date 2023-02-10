{ config, pkgs, lib, home-manager, ... }:
with lib;
let
  cfg = config.os.base;
in
{
  options = {
    os.base = {
      hostname = mkOption {
        type = types.str;
        example = "hostname";
        description = mdDoc "The hostname of the system";
      };
      timezone = mkOption {
        type = types.str;
        example = "America/Chicago";
        description = mdDoc ''
          The timezone for the system
        '';
      };
      locale = mkOption {
        type = types.str;
        example = "en_US.UTF-8";
        description = mdDoc ''
          The locale for the system
        '';
      };
      packages = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          vim
          git
          wget
          age
        ];
        example = literalExpression [ "pkgs.vim" "pkgs.git" ];
        description = mdDoc ''
          Base system packages
        '';
      };
      # todo...
      admins = mkOption {
        type = types.listOf types.str;
        example = literalExpression [ "todo" ];
        description = mdDoc ''
          todo
        '';
      };
      # todo...
      stateVersion = mkOption {
        type = types.str;
        example = "22.11";
        description = mdDoc ''
          Read the manual:
          https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
        '';
      };
    };
  };

  config = {
    # todo: admins...
    users.mutableUsers = false;
    users.users.root.initialPassword = "test";

    i18n = {
      defaultLocale = cfg.locale;
      extraLocaleSettings = {
        LC_ADDRESS = cfg.locale;
        LC_IDENTIFICATION = cfg.locale;
        LC_MEASUREMENT = cfg.locale;
        LC_MONETARY = cfg.locale;
        LC_NAME = cfg.locale;
        LC_NUMERIC = cfg.locale;
        LC_PAPER = cfg.locale;
        LC_TELEPHONE = cfg.locale;
        LC_TIME = cfg.locale;
      };
    };

    networking = {
      hostName = cfg.hostname;
      firewall.enable = true;
    };

    environment.systemPackages = cfg.packages;

    system.stateVersion = cfg.stateVersion;
  };
}
