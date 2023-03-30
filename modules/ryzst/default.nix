{ config, ... }:
let
  hosts = config.ryzst.mek;
in
{
  imports = [ ./mek ./int ];

  ryzst.int = {
    dns = {
      server.nodes = with hosts; {
        inherit firewall;
      };
      client.nodes = with hosts; {
        inherit bed desktop laptop media wap;
      };
    };

    ntp = {
      server.nodes = with hosts; {
        inherit firewall;
      };
      client.nodes = with hosts; {
        inherit bed desktop laptop media wap;
      };
    };

    wg = {
      server.nodes = with hosts; {
        inherit firewall;
      };
      client.nodes = with hosts; {
        inherit bed desktop laptop media wap;
      };
    };
  };
}