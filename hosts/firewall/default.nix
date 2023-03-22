{ config, pkgs, ... }:
let
  ext = {
    nts = [
      "time.cloudflare.com"
      "oregon.time.system76.com"
    ];
    dns = {
      primary = {
        name = "cloudflare-dns.com";
        ip = "1.1.1.1";
      };
      secondary = {
        name = "dns.google";
        ip = "8.8.8.8";
      };
    };
  };
  lan = {
    interface = "ens19";
    ip = "192.168.0.1";
    address = "192.168.0.1/24";
    prefixLength = 24;
    subnet = "192.168.0.0/24";
    pool = "192.168.0.100 - 192.168.0.200";
  };
  wan = {
    interface = "ens18";
  };
  wireguard = {
    interface = "wg0";
    ip = "10.255.255.1";
    address = "10.255.255.1/24";
    prefixLength = 24;
    subnet = "10.255.255.0/24";
    port = 51820;
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
    openFirewall = false;
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
  ];

  #############

  # ip forwarding 
  boot.kernel.sysctl = {
    "net.ipv4.conf.allforwarding" = true;
  };

  systemd.network = {
    enable = true;
    netdevs = {
      ${wireguard.interface} = {
        netdevConfig = {
          Name = wireguard.interface;
          Kind = "wireguard";
          Description = "wireguard server";
        };
        wireguardConfig = {
          ListenPort = wireguard.port;
          PrivateKeyFile = "/secrets/wg0/pri.key"; # todo: gen wireguard key in install script
        };
        wireguardPeers = [
          # todo: generate from registered devices
          {
            wireguardPeerConfig = {
              AllowedIPs = [ "10.255.255.2/32" ];
              PublicKey = "todo";
            };
          }
        ];
      };
    };
    networks = {
      ${wireguard.interface} = {
        matchConfig = {
          Name = wireguard.interface;
        };
        networkConfig = {
          Address = wireguard.address;
        };
      };
      ${lan.interface} = {
        matchConfig = {
          Name = lan.interface;
        };
        networkConfig = {
          DHCP = "no";
          Address = lan.address;
        };
      };
      ${wan.interface} = {
        matchConfig = {
          Name = wan.interface;
        };
        networkConfig = {
          DHCP = "yes";
        };
      };

    };
  };

  # nat
  networking.nat = {
    enable = true;
    internalInterfaces = [ lan.interface wireguard.interface ];
    externalInterface = wan.interface;
  };

  # firewall
  networking.firewall = {
    enable = true;
    interfaces = {
      ${lan.interface} = {
        allowedTCPPorts = [ 22 53 ];
        allowedUDPPorts = [ 53 wireguard.port ];
      };
      ${wan.interface} = {
        allowedTCPPorts = [ 22 ];
      };
    };
  };

  # NTP server
  services.chrony = {
    enable = true;
    enableNTS = true;
    serverOption = "iburst";
    servers = ext.nts;
    extraConfig = ''
      allow ${lan.subnet}
      bindaddress ${lan.ip}
    '';
  };

  # dns server
  services.coredns = {
    enable = true;
    config = ''
      .:53 {
        bind ${lan.interface}
        forward . 127.0.0.1:5301 127.0.0.1:5302
        cache 3600
      }
      .:5301 { 
        bind 127.0.0.1
        forward . tls://${ext.dns.primary.ip} {
          tls_servername ${ext.dns.primary.name}
          health_check 5s
        }
      }
      .:5302 {
        bind 127.0.0.1
        forward . tls://${ext.dns.secondary.ip} {
          tls_servername ${ext.dns.secondary.name}
          health_check 5s
        }
      }
    '';
  };

  # dhcp
  services.kea = {
    dhcp4 = {
      enable = true;
      settings = {
        valid-lifetime = 86400;
        interfaces-config = {
          interfaces = [ lan.interface ];
        };
        lease-database = {
          name = "/var/lib/kea/dhcp4.leases";
          persist = true;
          type = "memfile";
        };
        subnet4 = [
          {
            pools = [{ pool = lan.pool; }];
            subnet = lan.subnet;
            option-data = [
              {
                name = "domain-name-servers";
                data = lan.ip;
                #data = pkgs.lib.strings.concatStringsSep "," ext.dns;
              }
              { name = "routers"; data = lan.ip; }
            ];
          }
        ];
      };
    };
  };
}
