{ config, ... }:
let
  hosts = config.ryzst.mek;
in
{
  imports = [ ./mek ./int ./idm ];

  ryzst.int = {
    cache = {
      server.nodes = with hosts; {
        inherit tin-jet;
      };
      client.nodes = with hosts; {
        inherit cat-jar ape-orc car-fan mud-orb ant-bot;
      };
    };

    dns = {
      server.nodes = with hosts; {
        inherit tin-jet;
      };
      client.nodes = with hosts; {
        inherit cat-jar ape-orc car-fan mud-orb ant-bot;
      };
    };

    git = {
      server.nodes = with hosts; {
        inherit tin-jet;
      };
      client.nodes = with hosts; {
        inherit cat-jar ape-orc car-fan;
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

    remote-build = {
      server.nodes = with hosts; {
        inherit tin-jet;
      };
      client.nodes = with hosts; {
        # TODO: remove ape-orc when ci is in place
        inherit ape-orc car-fan;
      };
    };

    syncthing = {
      server.nodes = with hosts; {
        inherit tin-jet;
      };
      client.nodes = with hosts; {
        inherit ape-orc cat-jar car-fan;
      };
      reading.nodes = with hosts; {
        inherit gas-ink;
      };
    };

    wg = {
      server.nodes = with hosts; {
        inherit tin-jet;
      };
      client.nodes = with hosts; {
        inherit cat-jar ape-orc car-fan mud-orb ant-bot gas-ink;
      };
    };
  };
}
