{ config, pkgs, ... }:
{
  users = {
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
      sshd.u2fAuth = false; # todo...
    };
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  time.timeZone = "America/Chicago";

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      permitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # forgive me
  nixpkgs.config.allowUnfree = true;
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
    gc = {
      automatic = true;
      persistent = true;
      randomizedDelaySec = "30min";
      dates = "weekly";
      options = ''
        --delete-older-than 30d;
      '';
    };
  };
  system = {
    # read manual:
    stateVersion = "22.11";
    autoUpgrade = {
      enable = true;
      persistent = true;
      randomizedDelaySec = "30min";
      dates = "daily";
      allowReboot = false;
      flake = "github:rrrbbbsss/ryzst-systems";
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    age
    nftables
    wireguard-tools
    bind.dnsutils
  ];



}