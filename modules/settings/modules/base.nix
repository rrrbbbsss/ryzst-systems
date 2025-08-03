{ config, lib, pkgs, self, ... }:
with lib;
let
  cfg = config.os;
in
{
  # TODO: redo when remodel.
  options.device = {
    user = mkOption {
      type = types.nullOr self.lib.types.username;
      description = ''
        User assigned to device.
      '';
      default = null;
    };
  };

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

    #nftables
    networking.nftables.enable = true;

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
    };

    os = {
      locale = "en_US.UTF-8";
      timezone = "America/Chicago";
      domain = "mek.ryzst.net";
      flake = "git+ssh://git@git.int.ryzst.net/domain";
    };

    # boot entries
    boot.loader.systemd-boot.configurationLimit = 10;

    #updates
    os.upgrade.enable = true;
    os.reboot.enable = true;

    # having 3 different timers for gc is sort of annoying...
    os.misc-gc.enable = true;

    # version
    system.stateVersion = config.ryzst.mek."${cfg.hostname}".version;

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
      pciutils
      usbutils
    ];

    # faster reboot
    systemd.extraConfig = ''
      DefaultTimeoutStopSec=10s
    '';
    systemd.user.extraConfig = ''
      DefaultTimeoutStopSec=10s
    '';

    # fix ssh logout for alacritty
    programs.bash.logout = ''
      printf "\e]0;''${TERM^}\a"
    '';

    # vim is used instead of nano
    programs.nano.enable = false;

    # disable this
    programs.command-not-found.enable = false;

    # too slow
    documentation.man.generateCaches = false;

    # increase entropy
    services.jitterentropy-rngd.enable = true;

    # https://github.com/NixOS/nixpkgs/security/advisories/GHSA-m7pq-h9p4-8rr4
    systemd.shutdownRamfs.enable = false;

    # https://www.openwall.com/lists/oss-security/2025/05/29/3
    boot.kernel.sysctl."fs.suid_dumpable" = 0;

    # iwlwifi plague
    # you might have to disable wifi in BIOS,
    # then reboot, then re-enable wifi in BIOS.
    boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_15;
  };
}
