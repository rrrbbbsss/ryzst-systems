{ ... }:
{
  systemd.network = {
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
}
