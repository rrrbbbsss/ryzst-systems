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
      # todo: use nur for firefox addons 
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
        text-scaling-factor = 1.25;
      };
      "org/gnome/shell" = {
        enabled-extensions = [ "dash-to-dock@micxgx.gmail.com" ];
        disable-user-extension = false;
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
      "org/gnome/shell/extensions/dash-to-dock" = {
        dock-position = "LEFT";
        extend-height = true;
        dock-fixed = true;
        custom-theme-srhink = true;
        icon-size-fixed = true;
        dash-max-icon-size = 48;
      };
    };

    home.stateVersion = "22.11";
    home.packages = with pkgs; [

      #utilities
      ryzst.cli

      #audio/music
      spotify

      #games
      steam
      ryzst.sabaki
    ];
  };
}
