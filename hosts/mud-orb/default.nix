{ pkgs, config, lib, ... }:
let
  username = config.networking.hostName;
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
  volume = pkgs.writeShellApplication {
    name = "volume";
    runtimeInputs = with pkgs; [ pulseaudio wireplumber gawk eww ];
    text = ''
      case $1 in
        increase)
          pactl set-sink-volume @DEFAULT_SINK@ +5%
          ;;
        decrease)
          pactl set-sink-volume @DEFAULT_SINK@ -5%
          ;;
        mute)
          pactl set-sink-mute @DEFAULT_SINK@ toggle
          ;;
        *)
          exit 1
          ;;
      esac

      VOLUME=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{ print $2*100 }')
      MUTED=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{ print $2 }')

      eww open audio --duration 3s --arg muted="$MUTED" --arg vol="$VOLUME"
    '';
  };
  commands = {
    media = {
      raiseVolume = "${volume}/bin/volume increase";
      lowerVolume = "${volume}/bin/volume decrease";
      mute = "${volume}/bin/volume mute";
      micMute = "${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
      play = "${pkgs.playerctl}/bin/playerctl play-pause";
      next = "${pkgs.playerctl}/bin/playerctl next";
      prev = "${pkgs.playerctl}/bin/playerctl previous";
    };
  };

  # maximum jank:
  # play wav files to send IR signals to power on/off tv/receiver.
  # https://github.com/S-shangli/lirc_rawcode2wav
  playIR = pkgs.writeShellApplication {
    name = "playIR";
    runtimeInputs = with pkgs; [ mpv ];
    text = ''
      mpv --audio-device=alsa/front:CARD=PCH,DEV=0 ${./ir/receiver.wav}
      mpv --audio-device=alsa/front:CARD=PCH,DEV=0 --volume=200 ${./ir/tv.wav}
    '';
  };
  suspendIR = pkgs.writeShellApplication {
    name = "suspendIR";
    runtimeInputs = [ playIR pkgs.systemd ];
    text = ''
      playIR
      systemctl suspend
    '';
  };
  # TODO: playIR on startup/sleep/reboot/shutdown
in
{
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    hashedPassword = null;
    extraGroups = [ "seat" ];
  };

  services.seatd.enable = true;
  # required for powermenu
  security.polkit.enable = lib.mkForce true;


  nix.settings.allowed-users = [ username ];

  # bar disappears when monitor powers on/off
  services.udev.extraRules = ''
    ACTION=="change", \
    SUBSYSTEM=="drm", \
    RUN+="${pkgs.systemd}/bin/systemctl -M ${username}@ start --user bar.service"
  '';

  home-manager.users.${username} = { pkgs, config, osConfig, ... }: {
    imports = [
      ./eww
      ./media-powermenu
    ];

    dconf = {
      enable = true;
      settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
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
          "privacy.trackingprotection.enabled" = true;
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
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "browser.tabs.inTitlebar" = 0;
        };
        search = {
          force = true;
          engines = {
            "bing".metaData.hidden = true;
            "amazondotcom-us".metaData.hidden = true;
            "ebay".metaData.hidden = true;
          };
        };
        extensions.packages = with pkgs.firefox-addons; [
          ublock-origin
        ];
      };
    };

    home.stateVersion = "22.11";
    home.packages = with pkgs; [
      adwaita-icon-theme
      ryzst.fzf-wifi
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
      size = 32;
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
          timeout = 900;
          command = "${suspendIR}/bin/suspendIR";
          resumeCommand = "${playIR}/bin/playIR";
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
        input = osConfig.device.rats;
        output = {
          "*" = { bg = "${colors.desktop} solid_color"; scale = "2"; };
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
          commands = [
            {
              command = "inhibit_idle fullscreen";
              criteria = {
                class = ".*";
              };
            }
            {
              command = "inhibit_idle fullscreen";
              criteria = {
                app_id = ".*";
              };
            }
            {
              command = "move scratchpad; scratchpad show";
              criteria = {
                app_id = "Alacritty";
              };
            }
          ];
        };
        keybindings = {
          "${modifier}+Return" = ''
            exec swaymsg [app_id="Alacritty"] scratchpad show || ${pkgs.alacritty}/bin/alacritty
          '';
          "${modifier}+p" = "exec ${playIR}/bin/playIR";
          "XF86AudioRaiseVolume" = "exec ${commands.media.raiseVolume}";
          "XF86AudioLowerVolume" = "exec ${commands.media.lowerVolume}";
          "XF86AudioMute" = "exec ${commands.media.mute}";
          "XF86AudioMicMute" = "exec ${commands.media.micMute}";
          "${modifier}+XF86AudioMute" = "exec ${commands.media.micMute}";
          "XF86AudioPlay" = "exec ${commands.media.play}";
          "XF86AudioNext" = "exec ${commands.media.next}";
          "XF86AudioPrev" = "exec ${commands.media.prev}";
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
      unixAuth = false;
    };
  };
  programs.dconf.enable = true;
  programs.xwayland.enable = true;
  xdg.portal = {
    enable = true;
    config.common.default = "*";
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
      nerd-fonts.dejavu-sans-mono
    ];
  };
  # Sound
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
}
