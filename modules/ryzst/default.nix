{ config, ... }:
let
  hosts = config.ryzst.mek;
in
{
  imports = [ ./mek ./int ];

  ryzst.int = {
    dns = {
      server.nodes = with hosts; {
        inherit tin-jet;
      };
      client.nodes = with hosts; {
        inherit cat-jar ape-orc car-fan mud-orb ant-bot;
      };
    };

    nfs = {
      server.nodes = with hosts; {
        inherit tin-jet;
      };
      client.nodes = with hosts; {
        inherit cat-jar ape-orc;
      };
    };

    ntp = {
      server.nodes = with hosts; {
        inherit tin-jet;
      };
      client.nodes = with hosts; {
        inherit cat-jar ape-orc car-fan mud-orb ant-bot;
      };
    };

    syncthing = {
      server.nodes = with hosts; {
        inherit tin-jet;
      };
      client.nodes = with hosts; {
        inherit ape-orc cat-jar car-fan;
      };
    };

    wg = {
      server.nodes = with hosts; {
        inherit tin-jet;
      };
      client.nodes = with hosts; {
        inherit cat-jar ape-orc car-fan mud-orb ant-bot;
      };
    };
  };
}
