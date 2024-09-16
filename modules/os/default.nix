{ config, lib, pkgs, self, ... }:
with lib;
let
  cfg = config.os;
in
{
  imports = [
    ./auth.nix
    ./nix.nix
    ./grafting.nix
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
      type = self.outputs.lib.types.hostname;
      example = "computer";
      description = "hostname";
    };
    domain = mkOption {
      type = types.str;
      default = "mek.ryzst.net";
      description = "domain";
    };
    subnet = mkOption {
      type = types.str;
      default =
        let
          hash = builtins.hashString "sha256" config.os.domain;
        in
        "fd${substring 0 2 hash}:${substring 2 4 hash}:${substring 4 4 hash}::/48";
      description = "internal subnet";
    };
    flake = mkOption {
      type = types.str;
      example = "git+ssh://git@git.int.ryzst.net/domain";
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

    # mDNS
    networking.firewall.allowedUDPPorts = [ 5353 ];

    services.resolved = {
      enable = true;
      llmnr = "false";
      fallbackDns = [ ];
      extraConfig = ''
        MulticastDNS=resolve
      '';
    };
    systemd.network = {
      enable = true;
      wait-online.enable = false;
      networks = {
        wired = {
          matchConfig = {
            Name = "en*";
          };
          networkConfig = {
            DHCP = "ipv4";
            MulticastDNS = "resolve";
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
      openssl
      iputils
    ];

    # vim is used instead of nano
    programs.nano.enable = false;

    documentation.man.generateCaches = true;
  };
}
