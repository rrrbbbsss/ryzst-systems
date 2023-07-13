{ config, ... }:
let
  hosts = config.ryzst.mek;
in
{
  imports = [ ./mek ./int ];

  ryzst.int = {
    dns = {
      server.nodes = with hosts; {
        inherit brunhild;
      };
      client.nodes = with hosts; {
        inherit bed desktop laptop media wap;
      };
    };

    nfs = {
      server.nodes = with hosts; {
        inherit brunhild;
      };
      client.nodes = with hosts; {
        inherit bed desktop;
      };
    };

    ntp = {
      server.nodes = with hosts; {
        inherit brunhild;
      };
      client.nodes = with hosts; {
        inherit bed desktop laptop media wap;
      };
    };

    wg = {
      server.nodes = with hosts; {
        inherit brunhild;
      };
      client.nodes = with hosts; {
        inherit bed desktop laptop media wap;
      };
    };
  };
}
