{ pkgs, config, ... }:
let
  username = config.device.user;
in
{
  device.user = "media";

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    hashedPassword = null;
  };

  home-manager.users.${username} = { pkgs, ... }: {
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





  # Desktop
  services.xserver = {
    enable = true;
    displayManager = {
      gdm = {
        enable = true;
        autoLogin.delay = 5;
      };
      autoLogin = {
        enable = true;
        user = "media";
      };
    };
    desktopManager.gnome = {
      enable = true;
      extraGSettingsOverrides = ''
        [org.gnome.desktop.lockdown]
        disable-lock-screen = true
        disable-log-out = true
        disable-user-switching = true
      '';
    };
  };

  environment.gnome.excludePackages = with pkgs; [
    gnome-photos
    gnome-tour
    gnome.cheese
    gnome.epiphany
    gnome.geary
    gnome.totem
    gnome.simple-scan
    gnome.gnome-calendar
    gnome.gnome-contacts
    gnome.gnome-music
  ];

  environment.variables = {
    GTK_THEME = "Adwaita:dark";
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      dejavu_fonts
      (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
      font-awesome
      roboto
    ];
  };

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
}
