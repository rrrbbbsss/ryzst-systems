{ config, ... }:
let
  hosts = config.ryzst.mek.hosts;
in
{
  imports = [ ./mek ./int ];

  ryzst.int = {
    dns = {
      server.nodes = with hosts; {
        inherit firewall;
      };
      client.nodes = with hosts; {
        inherit bed desktop laptop media;
      };
    };

    ntp = {
      server.nodes = with hosts; {
        inherit firewall;
      };
      client.nodes = with hosts; {
        inherit bed desktop laptop media;
      };
    };

    wg = {
      server.nodes = with hosts; {
        inherit firewall;
      };
      client.nodes = with hosts; {
        inherit bed desktop laptop media;
      };
    };
  };
}