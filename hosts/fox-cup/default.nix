{ self, lib, ... }:
{
  imports = [
    self.idm.users.man.module
  ];

  # TODO: remove eventually...
  specialisation = {
    roaming.configuration = {
      ryzst.int.cache.client.nodes = lib.mkForce { };
      ryzst.int.dns.client.nodes = lib.mkForce { };
      ryzst.int.ntp.client.nodes = lib.mkForce { };
      ryzst.int.wg.client.nodes = lib.mkForce { };

      networking.nameservers = [ "1.1.1.1" ];
      services.resolved.dnsovertls = "true";
    };
  };
}
