{ config, lib, self, ... }:
let
  username = config.device.user;
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
  };

  home-manager.users.${username} = { pkgs, ... }: {
    imports = [
      ./config/alacritty
      ./config/emacs
      ./config/firefox
      ./config/gpg
      ./config/mpv
      ./config/vscode
      ./config/waybar
      ./config/zathura
    ];

    programs.password-store = {
      enable = true;
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

    programs.tealdeer = {
      enable = true;
      settings = {
        updates = {
          auto_update = true;
          auto_update_interval_hours = 720;
        };
      };
    };

    programs.bottom = {
      enable = true;
    };

    systemd.user.tmpfiles.rules = [
      "e /home/${username}/.local/share/Trash - - - 3w"
      "e /home/${username}/.cache             - - - 3w"
    ];

    home.stateVersion = "22.11";
    home.packages = with pkgs; [
      #fzf scripts
      ryzst.fzf-wifi
      ryzst.fzf-pass

      #browsers 
      chromium

      #spelling
      (aspellWithDicts (dicts: with dicts; [ en ]))

      #utils
      nix-tree
      git
      strace
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
      virt-manager
      pavucontrol
      qpwgraph

      #print/scan
      gnome.simple-scan

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
      ryzst.adom
      ryzst.adom-gui
    ];
  };
}
