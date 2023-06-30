{ config, pkgs, home-manager, ... }:
{

  #############
  ### Users ###
  #############
  users.users.media = {
    isNormalUser = true;
    description = "media";
    extraGroups = [ "networkmanager" ];
    hashedPassword = null;
  };
  networking.networkmanager.enable = true;

  #####################
  ### Homes Manager ###
  #####################
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.media = { pkgs, ... }: {
    programs.home-manager = {
      enable = true;
    };

    programs.firefox = {
      enable = true;
      profiles.default = {
        id = 0;
        isDefault = true;
        settings = {
          "browser.startup.homepage" = "https://google.com";
          "browser.newtabpage.enabled" = false;
          "extensions.pocket.enabled" = false;
        };
        extensions = with pkgs.firefox-addons; [
          ublock-origin
        ];
      };
    };


    programs.mpv = {
      enable = true;
    };

    dconf.settings = {
      "org/gnome/desktop/background" = {
        primary-color = "#180d26";
        secondary-color = "#180d26";
        color-shading-type = "solid";
        picture-options = "none";
      };
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        text-scaling-factor = 1.5;
      };
      "org/gnome/shell" = {
        favorite-apps = [
          "firefox.desktop"
          "spotify.desktop"
          "steam.desktop"
          "sabaki.desktop"
          "org.gnome.Weather.desktop"
          "org.gnome.Nautilus.desktop"
          "org.gnome.Console.desktop"
        ];
      };
    };

    home.stateVersion = "22.11";
    home.packages = with pkgs; [
      #audio/music
      spotify

      #games
      steam
      ryzst.sabaki
    ];
  };
}
