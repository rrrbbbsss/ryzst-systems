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
