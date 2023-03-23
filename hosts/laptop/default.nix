{ config, pkgs, ... }:
let
  wireguard = {
    client = {
      interface = "wg0";
      ip = "10.255.255.2";
      address = "10.255.255.2/24";
      port = 51820;
    };
    hub = {
      ip = "10.255.255.1";
      endpoint = "192.168.0.1";
      subnet = "10.255.255.0/24";
      port = 51820;
      publicKey = "25o3/I0MWQJMzEJ9+6ipCFaSZtCkETblvhGnivDu0Q0=";
    };
  };
in
{
  imports = [
    ../../modules/profiles/base.nix
    ../../modules/profiles/sway.nix
    ../../idm/users/rrrbbbsss
  ];

  # wireguard 
  networking.wireguard.interfaces = {
    ${wireguard.client.interface} = {
      ips = [ wireguard.client.address ];
      listenPort = wireguard.client.port;
      privateKeyFile = "/persist/secrets/wg0_key";
      peers = [
        {
          publicKey = wireguard.hub.publicKey;
          allowedIPs = [ wireguard.hub.subnet ];
          endpoint = "${wireguard.hub.endpoint}:${builtins.toString wireguard.hub.port}";
          persistentKeepalive = 10; # disable if roaming device
        }
      ];
    };
  };
}






