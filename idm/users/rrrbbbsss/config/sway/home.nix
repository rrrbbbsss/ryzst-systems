{ pkgs, osConfig, config, lib, ... }:

let
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
  wrap-float-window = window-name: command: ''
    ${commands.terminal} --title '${window-name}' --class '__float__' -e \
    ${command}
  '';
  commands = {
    workspace-cmd = "${pkgs.writeShellApplication {
      name = "workspace-cmd";
      runtimeInputs = [ pkgs.sway pkgs.jq ];
      text = ''
        monitors="${pkgs.writeText "device-monitors.json"
          (builtins.toJSON osConfig.device.monitors)}"
        focused=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused == true) | .name')
        prefix=$(jq -r '."'"$focused"'".number' $monitors)
        name="$prefix""$2"
        case $1 in
          "focus")
            swaymsg workspace "$name"
          ;;
          "move")
            swaymsg move container to workspace "$name"
            swaymsg workspace "$name"
          ;;
          *)
            exit 1
          ;;
        esac
      '';
    }}/bin/workspace-cmd";
    terminal = "${pkgs.alacritty}/bin/alacritty";
    applancher = wrap-float-window "FZF-Launcher" ''
      ${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop \
      &> /dev/null \
      --dmenu="${pkgs.fzf}/bin/fzf --reverse --prompt 'Launch > '" \
      --wrapper='swaymsg exec' \
      --term="${commands.terminal}" \
      --usage-log="''${XDG_CACHE_DIR:-$HOME/.cache}/fzf-launcher" \
      --no-generic
    '';
    browser = "${config.programs.firefox.package}/bin/firefox";
    passwords = wrap-float-window "FZF-Pass"
      "${pkgs.ryzst.fzf-pass}/bin/fzf-pass";
    wifi = wrap-float-window "FZF-Wifi" ''
      bash -c '${pkgs.ryzst.fzf-wifi}/bin/fzf-wifi && sleep 1'
    '';
    windows = wrap-float-window "FZF-Windows"
      "${pkgs.ryzst.fzf-sway-windows}/bin/fzf-sway-windows";
    screenshot = ''
      ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - \
      | ${config.programs.swappy.package}/bin/swappy -f -
    '';
    colorpicker = "${pkgs.writeShellApplication {
          name = "colorpicker";
          runtimeInputs = with pkgs; [
            hyprpicker
            wl-clipboard
          ];
          text = ''
            hyprpicker --no-fancy --render-inactive --autocopy
          '';
        }}/bin/colorpicker";
    editor = "${config.services.emacs.package}/bin/emacsclient -c";
    scratchpad = ''
      swaymsg [title="TODO"] scratchpad show \
      || ${commands.editor} -F '(quote (name . "TODO"))' /nfs/Notes/todos.org
    '';
    music = ''
      swaymsg [title="MUSIC"] scratchpad show \
      || exec ${wrap-float-window "MUSIC" "${config.programs.ncspot.package}/bin/ncspot"}
    '';
    lockscreen = "${pkgs.writeShellApplication {
        name = "lockscreen";
        runtimeInputs = [
          pkgs.pulseaudio
          pkgs.playerctl
          config.programs.swaylock.package
        ];
        text = ''
          swaylock -f
          pactl set-sink-mute @DEFAULT_SINK@ 1
          playerctl -a pause
        '';
    }}/bin/lockscreen";
    exit =
      let
        app = pkgs.writeShellApplication {
          name = "exit";
          runtimeInputs = [
            config.programs.fzf.package
            config.wayland.windowManager.sway.package
            pkgs.systemd
          ];
          text = ''
            actions="${pkgs.writeText "exit-actions.json"
              (builtins.toJSON {
                exit = "swaymsg exit";
                lock = commands.lockscreen;
                suspend = "systemctl suspend";
                reboot = "systemctl reboot";
                shutdown = "systemctl poweroff";
              })}"
            options=$(jq -r 'keys[]' "$actions")
            selection=$(fzf --reverse --prompt 'Exit > ' <<<"$options")
            action=$(jq -r ".$selection" "$actions")
            swaymsg exec "$action"
          '';
        };
      in
      wrap-float-window "FZF-Launcher" "${app}/bin/exit";
    media = {
      raiseVolume = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
      lowerVolume = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
      mute = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
      micMute = "${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
      play = "${pkgs.playerctl}/bin/playerctl play-pause";
      next = "${pkgs.playerctl}/bin/playerctl next";
      prev = "${pkgs.playerctl}/bin/playerctl previous";
    };
    screen = {
      raiseBrightness = "${pkgs.brightnessctl}/bin/brightnessctl set 5%+";
      lowerBrightness = "${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
    };
  };
in

{
  home.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
    NIXOS_OZONE_WL = "1";
  };

  home.packages = with pkgs; [
    swaylock
    swayidle
    swaybg
    wl-clipboard
    wlr-randr
    gnome.adwaita-icon-theme
  ];

  #cursor
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Original-Classic";
    size = 16;
  };
  gtk.enable = true;

  programs.swaylock = {
    settings = {
      scaling = "center";
      inherit font;
      font-size = 0.0;
      indicator-idle-visible = true;
      #default
      color = colors.desktop;
      bs-hl-color = colors.borders;
      inside-color = colors.transparent;
      key-hl-color = colors.yellow;
      ring-color = colors.black;
      line-color = colors.yellow;
      text-color = colors.transparent;
      #caps-lock
      disable-caps-lock-text = true;
      indicator-caps-lock = true;
      caps-lock-bs-hl-color = colors.borders;
      caps-lock-key-hl-color = colors.red;
      inside-caps-lock-color = colors.transparent;
      ring-caps-lock-color = colors.black;
      line-caps-lock-color = colors.red;
      text-caps-lock-color = colors.transparent;
      #clear
      inside-clear-color = colors.yellow + "33";
      ring-clear-color = colors.black;
      line-clear-color = colors.yellow;
      text-clear-color = colors.transparent;
      #verify
      inside-ver-color = colors.green + "33";
      ring-ver-color = colors.black;
      line-ver-color = colors.green;
      text-ver-color = colors.transparent;
      #wrong
      inside-wrong-color = colors.red + "33";
      ring-wrong-color = colors.black;
      line-wrong-color = colors.red;
      text-wrong-color = colors.transparent;
    };
  };
  services.swayidle = {
    enable = true;
    extraArgs = [ "-w" ];
    timeouts = [
      {
        timeout = 600;
        command = commands.lockscreen;
      }
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
    events = [
      {
        event = "before-sleep";
        command = commands.lockscreen;
      }
      {
        event = "lock";
        command = commands.lockscreen;
      }
    ];
  };

  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    wrapperFeatures.gtk = true;
    extraConfigEarly = ''
      exec swaymsg rename workspace 1 to 01
      titlebar_border_thickness 2
      titlebar_padding 5 3
    '';
    config = {
      inherit modifier;
      inherit (commands) terminal;
      menu = commands.applancher;
      fonts = {
        names = [ font ];
        size = 9.0;
      };
      bars = [ ];
      workspaceLayout = "tabbed";
      gaps = {
        inner = 7;
      };
      seat = {
        "*" = {
          xcursor_theme = with config.home.pointerCursor;
            "${name} ${builtins.toString size}";
          hide_cursor = "when-typing enable";
        };
      };
      input = {
        "*" = {
          repeat_delay = "300";
          repeat_rate = "30";
        };
      } // osConfig.device.rats;
      output = {
        "*" = { bg = "${colors.desktop} solid_color"; };
      } // (builtins.mapAttrs (n: v: (builtins.removeAttrs v [ "number" ]))
        osConfig.device.monitors);
      workspaceOutputAssign = lib.attrsets.foldlAttrs
        (acc: n: v:
          (builtins.map
            (x: {
              output = n;
              workspace = v.number + (builtins.toString x);
            })
            (builtins.genList (x: x + 1) 9)) ++ acc)
        [ ]
        osConfig.device.monitors;
      modes = {
        resize = {
          h = "resize shrink width 10 px";
          j = "resize grow height 10 px";
          k = "resize shrink height 10 px";
          l = "resize grow width 10 px";
          Escape = "mode default";

          "${modifier}+a" = "focus parent";
          "${modifier}+Shift+a" = "focus child";
          "${modifier}+h" = "focus left";
          "${modifier}+j" = "focus down";
          "${modifier}+k" = "focus up";
          "${modifier}+l" = "focus right";
        };
        passthrough = {
          "${modifier}+Escape" = "mode default";
        };
      };
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
        border = 2;
        commands = [
          {
            command = "move scratchpad; scratchpad show";
            criteria = {
              title = "(TODO|MUSIC)";
            };
          }
        ];
      };
      floating = {
        criteria = [{ app_id = "__float__"; }];
      };
      keybindings = {
        #windows
        "${modifier}+a" = "focus parent";
        "${modifier}+Shift+a" = "focus child";
        "${modifier}+h" = "focus left";
        "${modifier}+j" = "focus down";
        "${modifier}+k" = "focus up";
        "${modifier}+l" = "focus right";
        "${modifier}+Shift+h" = "move left";
        "${modifier}+Shift+j" = "move down";
        "${modifier}+Shift+k" = "move up";
        "${modifier}+Shift+l" = "move right";
        "${modifier}+Ctrl+h" = "focus output left";
        "${modifier}+Ctrl+j" = "focus output down";
        "${modifier}+Ctrl+k" = "focus output up";
        "${modifier}+Ctrl+l" = "focus output right";
        "${modifier}+Ctrl+i" = "workspace prev_on_output";
        "${modifier}+Ctrl+o" = "workspace next_on_output";
        "${modifier}+Ctrl+Shift+h" = "move output left; focus output left";
        "${modifier}+Ctrl+Shift+j" = "move output down; focus output down";
        "${modifier}+Ctrl+Shift+k" = "move output up; focus output up";
        "${modifier}+Ctrl+Shift+l" = "move output right; focus output right";
        "${modifier}+Ctrl+Shift+i" =
          "move workspace prev_on_output; workspace prev_on_output";
        "${modifier}+Ctrl+Shift+o" =
          "move workspace next_on_output; workspace next_on_output";
        "${modifier}+Shift+q" = "kill";
        #splits/layouts
        "${modifier}+s" = "splitv";
        "${modifier}+v" = "splith";
        "${modifier}+w" = "split toggle, layout tabbed";
        #floating
        "${modifier}+Shift+space" = "floating toggle";
        #fullscreen
        "${modifier}+f" = "fullscreen toggle";
        #workspaces
        "${modifier}+1" = "exec ${commands.workspace-cmd} focus 1";
        "${modifier}+2" = "exec ${commands.workspace-cmd} focus 2";
        "${modifier}+3" = "exec ${commands.workspace-cmd} focus 3";
        "${modifier}+4" = "exec ${commands.workspace-cmd} focus 4";
        "${modifier}+5" = "exec ${commands.workspace-cmd} focus 5";
        "${modifier}+6" = "exec ${commands.workspace-cmd} focus 6";
        "${modifier}+7" = "exec ${commands.workspace-cmd} focus 7";
        "${modifier}+8" = "exec ${commands.workspace-cmd} focus 8";
        "${modifier}+9" = "exec ${commands.workspace-cmd} focus 9";
        #move workspaces
        "${modifier}+Shift+1" = "exec ${commands.workspace-cmd} move 1";
        "${modifier}+Shift+2" = "exec ${commands.workspace-cmd} move 2";
        "${modifier}+Shift+3" = "exec ${commands.workspace-cmd} move 3";
        "${modifier}+Shift+4" = "exec ${commands.workspace-cmd} move 4";
        "${modifier}+Shift+5" = "exec ${commands.workspace-cmd} move 5";
        "${modifier}+Shift+6" = "exec ${commands.workspace-cmd} move 6";
        "${modifier}+Shift+7" = "exec ${commands.workspace-cmd} move 7";
        "${modifier}+Shift+8" = "exec ${commands.workspace-cmd} move 8";
        "${modifier}+Shift+9" = "exec ${commands.workspace-cmd} move 9";
        #execute
        "${modifier}+Return" = "exec ${commands.terminal}";
        "${modifier}+d" = "exec ${commands.applancher}";
        "${modifier}+p" = "exec ${commands.passwords}";
        "${modifier}+n" = "exec ${commands.wifi}";
        "${modifier}+m" = "exec ${commands.music}";
        "${modifier}+F11" = "exec ${commands.colorpicker}";
        "${modifier}+F12" = "exec ${commands.screenshot}";
        "${modifier}+backslash" = "exec ${commands.editor}";
        "${modifier}+tab" = "exec ${commands.windows}";
        "${modifier}+apostrophe" = "exec ${commands.browser}";

        #scratchpad
        "${modifier}+Shift+Backspace" = "move scratchpad";
        "${modifier}+Backspace" = "exec ${commands.scratchpad}";
        #sway
        "${modifier}+Shift+c" = "reload";
        "${modifier}+Shift+e" = "exec ${commands.exit}";
        #modes
        "${modifier}+r" = "mode resize";
        "${modifier}+Shift+Escape" = "mode passthrough";
        #mediakeys
        "XF86AudioRaiseVolume" = "exec ${commands.media.raiseVolume}";
        "XF86AudioLowerVolume" = "exec ${commands.media.lowerVolume}";
        "XF86AudioMute" = "exec ${commands.media.mute}";
        "XF86AudioMicMute" = "exec ${commands.media.micMute}";
        "${modifier}+XF86AudioMute" = "exec ${commands.media.micMute}";
        "XF86AudioPlay" = "exec ${commands.media.play}";
        "XF86AudioNext" = "exec ${commands.media.next}";
        "XF86AudioPrev" = "exec ${commands.media.prev}";
        "XF86MonBrightnessUp" = "exec ${commands.screen.raiseBrightness}";
        "XF86MonBrightnessDown" = "exec ${commands.screen.lowerBrightness}";
      };
    };
  };
}
