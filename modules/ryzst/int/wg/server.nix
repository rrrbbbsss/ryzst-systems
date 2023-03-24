{ config, pkgs, lib, ... }:
with lib;
let
  # todo: get from "deployment" mapping
  server.ip = "10.255.255.1";
  server.subnet = "10.255.255.0/24";
  server.port = 51820;
  server.publicKey = "25o3/I0MWQJMzEJ9+6ipCFaSZtCkETblvhGnivDu0Q0=";
  server.endpoint = "192.168.0.1";

  clients = attrsets.foldlAttrs
    (acc: n: v:
      [{ publicKey = v.keys.wg0; allowedIPs = [ "${v.ip}/32" ]; }] ++ acc)
    [ ]
    config.ryzst.mek.hosts;
in
{
  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "${server.ip}/24" ];
      listenPort = server.port;
      privateKeyFile = "/persist/secrets/wg0_key";
      peers = clients;
    };
  };
}