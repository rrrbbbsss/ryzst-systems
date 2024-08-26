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
        inherit (hosts) cat-jar ape-orc car-fan mud-orb ant-bot;
      };
    };

    dns = {
      server.nodes = {
        inherit (hosts) tin-jet;
      };
      client.nodes = {
        inherit (hosts) cat-jar ape-orc car-fan mud-orb ant-bot;
      };
    };

    git = {
      server.nodes = {
        inherit (hosts) tin-jet;
      };
      client.nodes = {
        inherit (hosts) cat-jar ape-orc car-fan;
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
        inherit (hosts) cat-jar ape-orc car-fan mud-orb ant-bot;
      };
    };

    remote-build = {
      server.nodes = {
        inherit (hosts) tin-jet;
      };
      client.nodes = {
        # TODO: remove ape-orc when ci is in place
        inherit (hosts) ape-orc car-fan;
      };
    };

    syncthing = {
      server.nodes = {
        inherit (hosts) tin-jet;
      };
      client.nodes = {
        inherit (hosts) ape-orc cat-jar car-fan;
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
        inherit (hosts) cat-jar ape-orc car-fan mud-orb ant-bot gas-ink;
      };
    };
  };
}
