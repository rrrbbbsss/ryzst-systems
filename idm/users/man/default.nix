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
    imports = [
      ./config/alacritty
      ./config/emacs
      ./config/firefox
      ./config/gpg
      ./config/mpv
      ./config/waybar
      ./config/zathura
    ];

    programs.password-store = {
      enable = true;
    };
    home.sessionVariables = {
      PASSWORD_STORE_CLIP_TIME = "20";
    };

    programs.git = {
      enable = true;
      userName = "Royce Strange";
      userEmail = "rrrbbbsss@ryzst.net";
      signing = {
        key = "6DB578354383FF64797A2D7E985AC6F0827B273C";
        signByDefault = true;
      };
      extraConfig = {
        init = {
          defaultBranch = "main";
        };
      };
    };

    programs.direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };


    programs.obs-studio = {
      enable = true;
    };

    programs.swappy = {
      enable = true;
      settings = {
        save_dir = "$HOME/Pictures/screenshots";
        show_panel = true;
        early_exit = true;
      };
    };

    programs.bottom = {
      enable = true;
    };

    systemd.user.tmpfiles.rules = [
      "e /home/${username}/.local/share/Trash - - - 3w"
      "e /home/${username}/.cache             - - - 3w"
    ];

    home.stateVersion = version;
    home.packages = with pkgs; [
      #fzf scripts
      ryzst.fzf-wifi
      ryzst.fzf-pass

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
      ripgrep
      fd
      bat
      pavucontrol
      qpwgraph
      oniux
      poop

      #print/scan
      simple-scan

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
      orca-slicer
    ];
  };
}
