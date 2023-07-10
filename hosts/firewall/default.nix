{ ... }:
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
  };
in
{
  imports = [ ];


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
