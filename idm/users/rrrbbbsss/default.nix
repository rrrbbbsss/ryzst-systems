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
    initialPassword = "test";
  };

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
      # todo: use nur for firefox addons 
    };

    services.flameshot = {
      enable = true;
    };

    home.stateVersion = "22.11";
    home.packages = with pkgs; [

      # misc utils
      jq
      ripgrep
      fd
      bat

      #browsers 
      chromium

      #terminal
      alacritty

      #nix
      nil
      nixpkgs-fmt

      #utilities
      ryzst.cli
      gnupg
      pinentry-curses
      qemu
      diffoscope
      hashcat
      htop
      git
      strace
      yubikey-manager
      usbutils
      ncdu
      age
      virt-manager

      #compression
      zip
      unzip
      p7zip
      zstd

      #file-utils
      tree
      file
      acl
      attr
      gptfdisk
      dosfstools
      exfat

      #net-utils
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

      #print/scan
      gnome.simple-scan

      #audio/music
      spotify
      pavucontrol

      #video
      yt-dlp
      ffmpeg

      #images
      graphviz
      xdot
      imagemagick
      gimp

      #games
      steam
      minecraft
      katago
      ryzst.katrain
      ryzst.sabaki
    ];
  };
}
