{ config, pkgs, ... }:
let
  lan = {
    interface = "ens19";
    address = "192.168.0.1";
    prefixLength = 24;
    subnet = "192.168.0.0/24";
    pool = "192.168.0.100 - 192.168.0.200";
  };
  wan = {
    interface = "ens18";
  };
in
{
  imports = [
    #../../modules/profiles/base.nix
  ];


  users = {
    mutableUsers = false;
    users.root = {
      hashedPassword = null;
      openssh.authorizedKeys.keys = import ../../idm/groups/admins.nix;
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
  ];

  #############

  # ip forwarding 
  boot.kernel.sysctl = {
    "net.ipv4.conf.allforwarding" = true;
  };

  # interfaces
  networking.interfaces = {
    ${lan.interface} = {
      useDHCP = false;
      ipv4.addresses = [
        { address = lan.address; prefixLength = lan.prefixLength; }
      ];
    };
    ${wan.interface} = {
      useDHCP = true;
    };
  };

  # nat
  networking.nat = {
    enable = true;
    internalInterfaces = [ lan.interface ];
    externalInterface = wan.interface;
  };

  # firewall
  networking.firewall = {
    enable = true;
  };

  # NTP server
  services.chrony = {
    enable = true;
    enableNTS = true;
    serverOption = "iburst";
    servers = [
      "time.cloudflare.com"
    ];
    extraConfig = ''
      allow ${lan.subnet}
      bindaddress ${lan.address}
    '';
  };

  # dhcp
  services.kea.dhcp4 = {
    enable = true;
    settings = {
      interfaces-config = {
        interfaces = [ lan.interface ];
      };
      lease-database = {
        name = "/var/lib/kea/dhcp4.leases";
        persist = true;
        type = "memfile";
      };
      rebind-timer = 2000;
      renew-timer = 1000;
      subnet4 = [
        {
          pools = [{ pool = lan.pool; }];
          subnet = lan.subnet;
          option-data = [
            { name = "domain-name-servers"; data = "8.8.8.8, 1.1.1.1"; }
            { name = "routers"; data = lan.address; }
          ];
        }
      ];
      valid-lifetime = 4000;
    };
  };
}
