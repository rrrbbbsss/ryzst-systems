{ config, pkgs, ... }:
let
  client.ip = config.ryzst.mek.hosts.${config.networking.hostName}.ip;
  client.address = "${client.ip}/24";
  client.port = 51820;
  # todo: get from deplyment mapping
  server = {
    ip = "10.255.255.1";
    endpoint = "192.168.0.1";
    subnet = "10.255.255.0/24";
    port = 51820;
    publicKey = "25o3/I0MWQJMzEJ9+6ipCFaSZtCkETblvhGnivDu0Q0=";
  };
in
{
  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "${client.address}" ];
      listenPort = client.port;
      privateKeyFile = "/persist/secrets/wg0_key";
      peers = [
        {
          publicKey = server.publicKey;
          allowedIPs = [ server.subnet ];
          endpoint = "${server.endpoint}:${builtins.toString server.port}";
          persistentKeepalive = 10; # disable if roaming device
        }
      ];
    };
  };
}
