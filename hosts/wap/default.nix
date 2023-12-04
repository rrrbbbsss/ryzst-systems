{ ... }:
let
  wifi = "wlan0";
  lan = "end0";
  bridge = "br0";
in
{

  imports = [ ];

  # TODO: redo
  services.hostapd = {
    enable = false;
  };

  networking.useDHCP = false;
  services.resolved.enable = false;
  systemd.network = {
    enable = true;
    netdevs = {
      ${bridge} = {
        netdevConfig = {
          Name = bridge;
          Kind = "bridge";
        };
      };
    };
    networks = {
      ${lan} = {
        matchConfig = {
          Name = lan;
        };
        networkConfig = {
          Bridge = bridge;
          DHCP = "no";
        };
      };
      ${bridge} = {
        matchConfig = {
          Name = bridge;
        };
        networkConfig = {
          DHCP = "ipv4";
        };
      };
    };
  };
}
