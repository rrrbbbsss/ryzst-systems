{ config, self, ... }:
let
  username = config.device.user;
  version = config.system.stateVersion;
in
{
  imports = [
    ./config/sway
    ./config/wireshark
    ./config/zsh
    ./config/ncspot
    ./config/alacritty
    ./config/emacs
    ./config/firefox
    ./config/gpg
    ./config/mpv
    ./config/waybar
    ./config/zathura
    ./config/pass
    ./config/git
  ];

  device.user = baseNameOf (toString ./.);

  users.users.${username} = {
    isNormalUser = true;
    uid = self.outputs.lib.names.user.toUID username;
    # TODO: full name
    description = username;
    hashedPassword = null;
    # TODO: don't do this here
    extraGroups = [ "wheel" ];
  };
  # this is required for home-manager-<user>.service
  nix.settings.allowed-users = [ username ];

  home-manager.users.${username} = { pkgs, ... }: {

    home.stateVersion = version;

    systemd.user.tmpfiles.rules = [
      "e /home/${username}/.local/share/Trash - - - 3w"
      "e /home/${username}/.cache             - - - 3w"
    ];

    programs.bottom = {
      enable = true;
    };

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
