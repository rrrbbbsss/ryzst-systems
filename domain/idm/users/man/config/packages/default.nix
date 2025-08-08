{ config, ... }:
{
  home-manager.users.${config.device.user} = { pkgs, ... }: {
    home.packages = with pkgs; [
      #browsers
      chromium
      ryzst.tails

      #spelling
      (aspellWithDicts (dicts: with dicts; [ en ]))

      #utils
      nix-index-with-db
      nix-tree
      git
      strace
      ltrace
      yubikey-manager
      usbutils
      ncdu
      age
      openssh
      openssl
      curl
      nmap
      netcat
      nettools
      tcpdump
      bind.dnsutils
      ethtool
      socat
      nftables
      tree
      file
      zip
      unzip
      p7zip
      zstd
      jq
      bat
      pavucontrol
      qpwgraph
      oniux
      poop
      bottom

      #video
      yt-dlp

      #images
      gimp
      drawio

      #games
      steam
      katago
      ryzst.katrain
      ryzst.sabaki
      ryzst.weiqihub
      ryzst.minifoxwq
      ryzst.foxwq-gym
      ryzst.adom
      ryzst.adom-gui
      ryzst.cho-ren-sha-68k

      #3d-printing
      freecad-wayland
    ];
  };
}
