{ config, pkgs, registry, ... }:
let
  wireguard = {
    client = {
      interface = "wg0";
      ip = "10.255.255.2";
      address = "10.255.255.2/24";
      port = 51820;
    };
    server = {
      ip = "10.255.255.1";
      endpoint = "192.168.0.1";
      subnet = "10.255.255.0/24";
      port = 51820;
      publicKey = "25o3/I0MWQJMzEJ9+6ipCFaSZtCkETblvhGnivDu0Q0=";
    };
  };
in
{
  config = {
    networking.wireguard.interfaces = {
      ${wireguard.client.interface} = {
        ips = [ wireguard.client.address ];
        listenPort = wireguard.client.port;
        privateKeyFile = "/persist/secrets/wg0_key";
        peers = [
          {
            publicKey = registry.wireguard.server.publicKey;
            allowedIPs = [ registry.wireguard.server.subnet ];
            endpoint = "${registry.wireguard.server.endpoint}:${builtins.toString env.wireguard.hub.port}";
            persistentKeepalive = 10; # disable if roaming device
          }
        ];
      };
    };
  };
}
