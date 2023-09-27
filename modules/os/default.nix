{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.os;
in
{
  imports = [
    ./auth.nix
    ./nix.nix
  ];
  options.os = {
    locale = mkOption {
      type = types.str;
      default = "en_US.UTF-8";
      defaultText = literalExpression "en_US.UTF-8";
      description = "locale";
    };
    timezone = mkOption {
      type = types.str;
      example = "America/Chicago";
      description = "timezone";
    };
    hostname = mkOption {
      type = types.str;
      example = "computer";
      description = "hostname";
    };
    domain = mkOption {
      type = types.str;
      default = "mek.ryzst.net";
      description = "domain";
    };
    flake = mkOption {
      type = types.str;
      example = "github:rrrbbbsss/ryzst-systems";
      description = "flake to grab updates from";
    };
  };

  config = {
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

    time.timeZone = cfg.timezone;

    networking = {
      inherit (cfg) domain;
      hostName = cfg.hostname;
      hostId = with builtins;
        substring 0 8 (hashString "sha256" cfg.hostname);
      useDHCP = false;
    };

    services.resolved.enable = false;
    systemd.network = {
      enable = true;
      networks = {
        wired = {
          matchConfig = {
            Name = "en*";
          };
          networkConfig = {
            DHCP = "ipv4";
          };
          dhcpV4Config = {
            UseDNS = false;
            UseHostname = false;
            UseDomains = false;
            UseTimezone = false;
            RouteMetric = 100;
          };
        };
      };
    };

    # base-packages
    environment.systemPackages = with pkgs; [
      ryzst.apps
      vim
      git
      wget
      age
      nftables
      wireguard-tools
      bind.dnsutils
    ];
  };
}
