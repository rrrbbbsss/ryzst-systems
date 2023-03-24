{ config, pkgs, ... }:
let
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
    subnet = "10.255.255.0/24";
    port = 51820;
    endpoint = lan.interface;
  };
in
{
  imports = [
    ../../modules/profiles/base.nix
    ../../modules/ryzst/int/dns/server.nix
    ../../modules/ryzst/int/ntp/server.nix
    ../../modules/ryzst/int/wg/server.nix
  ];

  ryzst.int.ntp.server = {
    enable = true;
    address = wireguard.ip;
    interface = wireguard.interface;
    allow = wireguard.subnet;
  };
  ryzst.int.dns.server = {
    enable = true;
    interface = wireguard.interface;
    allow = wireguard.subnet;
  };


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
    internalInterfaces = [ lan.interface wireguard.interface ];
    externalInterface = wan.interface;
  };

  # firewall
  networking.firewall = {
    enable = true;
    interfaces = {
      ${lan.interface} = {
        allowedUDPPorts = [ wireguard.port ];
      };
    };
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
                data = "1.1.1.1, 8.8.8.8";
              }
              { name = "routers"; data = lan.ip; }
            ];
          }
        ];
      };
    };
  };
}
