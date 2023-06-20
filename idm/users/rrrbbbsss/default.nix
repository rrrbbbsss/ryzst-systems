{ pkgs, ... }:
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
      ../../../modules/home
      ./config/alacritty
      ./config/emacs
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
          "signon.rememberSignons" = false;
          "network.IDN_show_punycode" = true;
          "geo.enabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "privacy.firstparty.isolate" = true;
          "privacy.resistFingerprinting" = false;
          "browser.cache.offline.enable" = false;
          "dom.battery.enabled" = false;
          "dom.event.clipboardevents.enabled" = false;
          "network.trr.mode" = 5;
          "dom.security.https_only_mode" = true;
          "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
          "browser.urlbar.suggest.quicksuggest.sponsored" = false;
          "extensions.formautofill.addresses.enabled" = false;
          "extensions.formautofill.creditCards.enabled" = false;
          "privacy.clearOnShutdown.offlineApps" = true;
          "privacy.clearOnShutdown.cookies" = true;
          "layout.css.prefers-color-scheme.content-override" = 0;
        };
        search = {
          force = true;
          engines = {
            "Bing".metaData.hidden = true;
            "Amazon.com".metaData.hidden = true;
            "eBay".metaData.hidden = true;
          };
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
