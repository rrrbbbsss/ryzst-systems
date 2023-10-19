{ pkgs, config, ... }:
let
  username = config.device.user;
  font = "DejaVu Sans Mono";
  colors = {
    desktop = "#0d0d0d";
    text = "#c5c8c6";
    borders = "#3f4040";
    unfocus-background = "#000000";
    unfocus-text = "#5a5b5a";
    focus-background = "#a16bed";
    focus-text = "#ffffff";
    yellow = "#f0c674";
    red = "#cc6666";
    green = "#b5bd68";
    black = "#000000";
    transparent = "#00000000";
  };
  modifier = "Mod4";
in
{

  device.user = config.networking.hostName;

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    hashedPassword = null;
  };

  home-manager.users.${username} = { pkgs, config, osConfig, ... }: {
    imports = [
      ./eww
    ];

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

    home.stateVersion = "22.11";
    home.packages = with pkgs; [
      gnome.adwaita-icon-theme
    ];


    #########
    home.sessionVariables = {
      GTK_THEME = "Adwaita:dark";
      NIXOS_OZONE_WL = "1";
    };

    #cursor
    home.pointerCursor = {
      gtk.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Original-Classic";
      size = 16;
    };
    gtk.enable = true;

    services.swayidle = {
      enable = true;
      extraArgs = [ "-w" ];
      timeouts = [
        {
          timeout = 630;
          command = ''${pkgs.sway}/bin/swaymsg "output * dpms off"'';
          resumeCommand = ''${pkgs.sway}/bin/swaymsg "output * dpms on"'';
        }
        {
          timeout = 3600;
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
    };

    wayland.windowManager.sway = {
      enable = true;
      xwayland = true;
      wrapperFeatures.gtk = true;
      config = {
        inherit modifier;
        fonts = {
          names = [ font ];
          size = 9.0;
        };
        bars = [ ];
        seat = {
          "*" = {
            xcursor_theme = with config.home.pointerCursor;
              "${name} ${builtins.toString size}";
            hide_cursor = "5000";
          };
        };
        output = {
          "*" = { bg = "${colors.desktop} solid_color"; };
        } // (builtins.mapAttrs (n: v: (builtins.removeAttrs v [ "number" ]))
          osConfig.device.monitors);
        colors = {
          background = colors.desktop;
          focused = {
            background = colors.borders;
            border = colors.focus-background;
            childBorder = colors.focus-background;
            indicator = colors.focus-background;
            text = colors.focus-text;
          };
          focusedInactive = {
            background = colors.borders;
            border = colors.borders;
            childBorder = colors.borders;
            indicator = colors.borders;
            inherit (colors) text;
          };
          unfocused = {
            background = colors.unfocus-background;
            border = colors.borders;
            childBorder = colors.borders;
            indicator = colors.borders;
            text = colors.unfocus-text;
          };
        };
        window = {
          border = 0;
        };
        keybindings = {
          "${modifier}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
        };
      };
    };

  };

  #services.getty.autologinUser = username;
  # Login Manager
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.sway}/bin/sway";
        user = username;
      };
      default_session = initial_session;
    };
    vt = 7;
  };
  security.pam.services = {
    greetd = {
      u2fAuth = true;
      unixAuth = false;
    };
  };
  security.polkit.enable = true;
  programs.dconf.enable = true;
  programs.xwayland.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };
  # use dark themes
  environment.variables = {
    GTK_THEME = "Adwaita:dark";
  };
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };
  # Fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      dejavu_fonts
      (nerdfonts.override { fonts = [ "DejaVuSansMono" ]; })
    ];
  };
  # Sound
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
