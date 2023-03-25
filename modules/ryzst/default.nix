{ config, ... }:
{
  imports = [ ./mek ./int ];

  ryzst.int = {
    dns = {
      server.nodes = [
        config.ryzst.mek.hosts.firewall
      ];
      client.nodes = [
        config.ryzst.mek.hosts.bed
        config.ryzst.mek.hosts.desktop
        config.ryzst.mek.hosts.laptop
        config.ryzst.mek.hosts.media
      ];
    };

    ntp = {
      server.nodes = [
        config.ryzst.mek.hosts.firewall
      ];
      client.nodes = [
        config.ryzst.mek.hosts.bed
        config.ryzst.mek.hosts.desktop
        config.ryzst.mek.hosts.laptop
        config.ryzst.mek.hosts.media
      ];
    };

    wg = {
      server.nodes = [
        config.ryzst.mek.hosts.firewall
      ];
      client.nodes = [
        config.ryzst.mek.hosts.bed
        config.ryzst.mek.hosts.desktop
        config.ryzst.mek.hosts.laptop
        config.ryzst.mek.hosts.media
      ];
    };
  };
}
