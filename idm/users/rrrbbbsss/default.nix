{ config, pkgs, home-manager, ... }:
{

  #############
  ### Users ###
  #############
  users.users.rrrbbbsss = {
    isNormalUser = true;
    description = "rrrbbbsss";
    extraGroups = [ "networkmanager" "wheel" "wireshark" "libvirtd" ];
    shell = pkgs.zsh;
    hashedPassword = null;
  };
  #todo: this needs to move out
  networking.networkmanager.enable = true;

  # for zsh shell
  programs.zsh.enable = true;
  environment.pathsToLink = [ "/share/zsh" ];

  # for wireshark
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };


  #####################
  ### Homes Manager ###
  #####################
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.rrrbbbsss = { pkgs, ... }: {
    imports = [
      ./config/alacritty
      ./config/gpg
      ./config/mpv
      ./config/nvim
      ./config/sway
      ./config/vscode
      ./config/waybar
      ./config/zathura
      ./config/zsh
    ];
    programs.home-manager = {
      enable = true;
    };

    programs.password-store = {
      enable = true;
    };

    programs.tmux = {
      enable = true;
    };

    programs.mbsync = {
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

    programs.firefox = {
      enable = true;
      profiles.default = {
        id = 0;
        isDefault = true;
        settings = {
          "browser.startup.homepage" = "https://google.com";
          "browser.newtabpage.enabled" = false;
          "media.ffmpeg.vaapi.enabled" = true;
          "extensions.pocket.enabled" = false;
          "extensions.autoDisableScopes" = 14;
        };
        extensions = with pkgs.firefox-addons; [
          ublock-origin
          tridactyl
        ];
      };
    };

    programs.obs-studio = {
      enable = true;
    };

    services.flameshot = {
      enable = true;
    };

    home.stateVersion = "22.11";
    home.packages = with pkgs; [

      #browsers 
      chromium

      #terminal
      alacritty

      #nix
      nil
      nixpkgs-fmt

      #utils
      ryzst.cli
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
