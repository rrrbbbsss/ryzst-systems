# btw, Sander van der Burg has ideas:
# http://sandervanderburg.nl/pdf/publications/vanderburg12-disnix.pdf
# i liked his distribution model,
# but need to add some more models at some point.
{ config, ... }:
let
  hosts = config.ryzst.mek;
in
{
  imports = [ ./mek ./int ./idm ];

  ryzst.int = {
    cache = {
      server.nodes = {
        inherit (hosts) tin-jet;
      };
      client.nodes = {
        inherit (hosts) fox-cup cat-jar ape-orc car-fan mud-orb ant-bot;
      };
    };

    ci = {
      server.nodes = {
        inherit (hosts) tin-jet;
      };
      client-rpc.nodes = {
        inherit (hosts) tin-jet;
      };
      client-web.nodes = {
        inherit (hosts) fox-cup cat-jar ape-orc car-fan;
      };
    };

    cups = {
      server.nodes = {
        inherit (hosts) ant-bot;
      };
      client.nodes = {
        inherit (hosts) fox-cup cat-jar ape-orc;
      };
    };

    dns = {
      server.nodes = {
        inherit (hosts) tin-jet;
      };
      client.nodes = {
        inherit (hosts) fox-cup cat-jar ape-orc car-fan mud-orb ant-bot;
      };
    };

    git = {
      server.nodes = {
        inherit (hosts) tin-jet;
      };
      client.nodes = {
        inherit (hosts) tin-jet fox-cup cat-jar ape-orc car-fan mud-orb ant-bot;
      };
    };

    nfs = {
      server.nodes = {
        inherit (hosts) tin-jet;
      };
      client.nodes = {
        inherit (hosts) cat-jar ape-orc;
      };
    };

    ntp = {
      server.nodes = {
        inherit (hosts) tin-jet;
      };
      client.nodes = {
        inherit (hosts) fox-cup cat-jar ape-orc car-fan mud-orb ant-bot;
      };
    };

    remote-build = {
      server.nodes = { };
      client.nodes = { };
    };

    syncthing = {
      server.nodes = {
        inherit (hosts) tin-jet;
      };
      client.nodes = {
        inherit (hosts) fox-cup ape-orc cat-jar car-fan;
      };
      reading.nodes = {
        inherit (hosts) gas-ink;
      };
    };

    wg = {
      server.nodes = {
        inherit (hosts) tin-jet;
      };
      client.nodes = {
        inherit (hosts) fox-cup cat-jar ape-orc car-fan mud-orb ant-bot gas-ink;
      };
    };
  };
}
