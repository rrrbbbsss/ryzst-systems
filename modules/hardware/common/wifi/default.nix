{ ... }:
{
  networking = {
    wireless.iwd.enable = true;
  };

  systemd.network = {
    enable = true;
    links = {
      wireless = {
        matchConfig = {
          name = "wl*";
        };
        linkConfig = {
          MACAddressPolicy = "random";
        };
      };
    };
    networks = {
      wireless = {
        matchConfig = {
          Name = "wl*";
        };
        networkConfig = {
          DHCP = "ipv4";
          IgnoreCarrierLoss = "3s";
        };
        dhcpV4Config = {
          UseDNS = false;
          UseHostname = false;
          UseDomains = false;
          UseTimezone = false;
          RouteMetric = 600;
          Anonymize = true;
        };
      };
    };
  };
}
