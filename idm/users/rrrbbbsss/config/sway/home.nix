{ pkgs, osConfig, config, ... }:

let
  modifier = "Mod4";
  commands = {
    terminal = ''${pkgs.alacritty}/bin/alacritty'';
    applancher = "${config.programs.fuzzel.package}/bin/fuzzel";
    passwords = ''
      ${pkgs.alacritty}/bin/alacritty --title 'FZF-Pass' --class '__float__' -e \
      ${pkgs.ryzst.fzf-pass}/bin/fzf-pass
    '';
    wifi = ''
      ${pkgs.alacritty}/bin/alacritty --title 'FZF-Wifi' --class '__float__' -e \
      bash -c '${pkgs.ryzst.fzf-wifi}/bin/fzf-wifi && sleep 1'
    '';
    screenshot = ''
      ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - \
      | ${pkgs.swappy}/bin/swappy -f -
    '';
    editor = "${config.services.emacs.package}/bin/emacsclient -c";
    scratchpad = ''
      [ "swaymsg -t get_tree | ${pkgs.jq.bin}/bin/jq '.. | .name? | select(. == "__scratchpad__")'" ] \
      && swaymsg "scratchpad show" \
      || ${commands.editor} -F '(quote (name . "__scratchpad__"))' /nfs/Notes/todos.org
    '';
    exit = "swaynag -t warning -m 'Do you really want to exit sway?' -b 'Yes' 'swaymsg exit'";
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
    waybar
    wl-clipboard
    wlr-randr
    gnome.adwaita-icon-theme
  ];

  programs.swaylock = {
    settings = {
      color = "180d26ff";
      line-color = "ae7eedff";
      indicator-idle-visible = true;
    };
  };

  services.swayidle = {
    enable = true;
    extraArgs = [ "-w" ];
    timeouts = [
      {
        timeout = 600;
        command = "${pkgs.swaylock}/bin/swaylock -f";
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
      { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
      { event = "before-sleep"; command = "${pkgs.playerctl}/bin/playerctl pause"; }
      { event = "lock"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
      { event = "lock"; command = "${pkgs.playerctl}/bin/playerctl pause"; }
    ];
  };

  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    wrapperFeatures.gtk = true;
    config = {
      inherit modifier;
      terminal = commands.terminal;
      menu = commands.applancher;
      fonts = {
        names = [ "DejaVu Sans Mono" ];
        size = 8.0;
      };
      bars = [{
        command = "waybar";
        position = "bottom";
      }];
      workspaceLayout = "tabbed";
      gaps = {
        inner = 7;
      };
      input = {
        "*" = {
          repeat_delay = "300";
          repeat_rate = "30";
        };
      } // osConfig.device.rats;
      output = {
        "*" = { bg = "#180d26 solid_color"; };
      } // osConfig.device.monitors;
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
        vm = {
          "${modifier}+Escape" = "mode default";
        };
      };
      colors = {
        background = "#ffffff";
        focused = {
          background = "#a16bed";
          border = "#a16bed";
          childBorder = "#a16bed";
          indicator = "#a16bed";
          text = "#ffffff";
        };
        focusedInactive = {
          background = "#333333";
          border = "#333333";
          childBorder = "#333333";
          indicator = "#333333";
          text = "#888888";
        };
      };
      window = {
        border = 2;
        commands = [
          {
            command = "move scratchpad; scratchpad show";
            criteria = {
              title = "__scratchpad__";
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
        "${modifier}+Ctrl+Shift+h" = "move output left; focus output left";
        "${modifier}+Ctrl+Shift+j" = "move output down; focus output down";
        "${modifier}+Ctrl+Shift+k" = "move output up; focus output up";
        "${modifier}+Ctrl+Shift+l" = "move output right; focus output right";
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
        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+6" = "workspace number 6";
        "${modifier}+7" = "workspace number 7";
        "${modifier}+8" = "workspace number 8";
        "${modifier}+9" = "workspace number 9";
        #move workspaces
        "${modifier}+Shift+1" = "move container to workspace number 1; workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2; workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3; workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4; workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5; workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6; workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7; workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8; workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace number 9; workspace number 9";
        #execute
        "${modifier}+Return" = "exec ${commands.terminal}";
        "${modifier}+d" = "exec ${commands.applancher}";
        "${modifier}+p" = "exec ${commands.passwords}";
        "${modifier}+n" = "exec ${commands.wifi}";
        "${modifier}+F12" = "exec ${commands.screenshot}";
        "${modifier}+backslash" = "exec ${commands.editor}";

        #scratchpad
        "${modifier}+Shift+Backspace" = "move scratchpad";
        "${modifier}+Backspace" = "exec ${commands.scratchpad}";
        #sway
        "${modifier}+Shift+c" = "reload";
        "${modifier}+Shift+e" = "exec ${commands.exit}";
        #modes
        "${modifier}+r" = "mode resize";
        "${modifier}+Shift+Escape" = "mode vm";
        #mediakeys
        "XF86AudioRaiseVolume" = "exec ${commands.media.raiseVolume}";
        "XF86AudioLowerVolume" = "exec ${commands.media.lowerVolume}";
        "XF86AudioMute" = "exec ${commands.media.mute}";
        "XF86AudioMicMute" = "exec ${commands.media.micMute}";
        "XF86AudioPlay" = "exec ${commands.media.play}";
        "XF86AudioNext" = "exec ${commands.media.next}";
        "XF86AudioPrev" = "exec ${commands.media.prev}";
        "XF86MonBrightnessUp" = "exec ${commands.screen.raiseBrightness}";
        "XF86MonBrightnessDown" = "exec ${commands.screen.lowerBrightness}";
      };
    };
  };
}