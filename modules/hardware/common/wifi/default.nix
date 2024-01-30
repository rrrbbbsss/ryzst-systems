{ lib, ... }:
{

  networking.wireless.enable = lib.mkForce false;

  networking.wireless.iwd = {
    enable = true;
    settings = {
      General = {
        UseDefaultInterface = false;
        AddressRandomization = "once";
        AddressRandomizationRange = "full";
      };
    };
  };

  systemd.network = {
    enable = true;
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
