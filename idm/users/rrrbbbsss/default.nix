{ config, pkgs, ... }:
let
  username = config.device.user;
in
{
  imports = [
    ./config/sway
    ./config/wireshark
    ./config/zsh
  ];

  device.user = "rrrbbbsss";

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "wheel" ];
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

    programs.fuzzel = {
      enable = true;
      settings = {
        border = {
          width = 3;
        };
        colors = {
          text = "ae7eedff";
          background = "180d26ff";
          border = "ae7eedff";
          selection = "ae7eedff";
          selection-text = "180d26ff";
        };
      };
    };

    programs.swappy = {
      enable = true;
      settings = {
        save_dir = "$HOME/Pictures/screenshots";
        show_panel = true;
        early_exit = true;
      };
    };

    home.stateVersion = "22.11";
    home.packages = with pkgs; [
      #fzf scripts
      ryzst.fzf-wifi
      ryzst.fzf-pass
      ryzst.fzf-nix-options

      #browsers 
      chromium

      #terminal
      alacritty

      #spelling
      aspell
      aspellDicts.en

      #nix
      nil
      nixpkgs-fmt

      #utils
      htop
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

      #print/scan
      gnome.simple-scan

      #music
      spotify
      pavucontrol

      #video
      yt-dlp
      ffmpeg

      #images
      gimp

      #games
      steam
      katago
      ryzst.katrain
      ryzst.sabaki
    ];
  };
}
