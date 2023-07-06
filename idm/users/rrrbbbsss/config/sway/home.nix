{ pkgs, osConfig, config, lib, ... }:

let
  inherit (lib.meta) getExe;
  modifier = "Mod4";
  wrap-float-window = window-name: command: ''
    ${commands.terminal} --title '${window-name}' --class '__float__' -e \
    ${command}
  '';
  commands = {
    workspace-cmd = getExe
      (pkgs.writeShellApplication {
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
      });
    terminal = getExe pkgs.alacritty;
    applancher = wrap-float-window "FZF-Launcher" ''
      ${getExe pkgs.j4-dmenu-desktop} \
      --dmenu="${getExe pkgs.fzf} --reverse --prompt 'Launch > '" \
      --wrapper='swaymsg exec' \
      --term="${commands.terminal}" \
      --usage-log="''${XDG_CACHE_DIR:-$HOME/.cache}/fzf-launcher" \
      --no-generic
    '';
    passwords = wrap-float-window "FZF-Pass"
      (getExe pkgs.ryzst.fzf-pass);
    wifi = wrap-float-window "FZF-Wifi" ''
      bash -c '${getExe pkgs.ryzst.fzf-wifi} && sleep 1'
    '';
    windows = wrap-float-window "FZF-Windows"
      (getExe pkgs.ryzst.fzf-sway-windows);
    screenshot = ''
      ${getExe pkgs.grim} -g "$(${getExe pkgs.slurp})" - \
      | ${getExe pkgs.swappy} -f -
    '';
    editor = "${config.services.emacs.package}/bin/emacsclient -c";
    scratchpad = ''
      [ "swaymsg -t get_tree | ${getExe pkgs.jq.bin} '.. | .name? | select(. == "__scratchpad__")'" ] \
      && swaymsg "scratchpad show" \
      || ${commands.editor} -F '(quote (name . "__scratchpad__"))' /nfs/Notes/todos.org
    '';
    exit = "swaynag -t warning -m 'Do you really want to exit sway?' -b 'Yes' 'swaymsg exit'";
    media = {
      raiseVolume = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
      lowerVolume = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
      mute = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
      micMute = "${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
      play = "${getExe pkgs.playerctl} play-pause";
      next = "${getExe pkgs.playerctl} next";
      prev = "${getExe pkgs.playerctl} previous";
    };
    screen = {
      raiseBrightness = "${getExe pkgs.brightnessctl} set 5%+";
      lowerBrightness = "${getExe pkgs.brightnessctl} set 5%-";
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
        command = "${getExe pkgs.swaylock} -f";
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
      { event = "before-sleep"; command = "${getExe pkgs.swaylock} -f"; }
      { event = "before-sleep"; command = "${getExe pkgs.playerctl} pause"; }
      { event = "lock"; command = "${getExe pkgs.swaylock} -f"; }
      { event = "lock"; command = "${getExe pkgs.playerctl} pause"; }
    ];
  };

  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    wrapperFeatures.gtk = true;
    extraConfigEarly = "exec swaymsg rename workspace 1 to 01";
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
      } // (builtins.mapAttrs (n: v: (builtins.removeAttrs v [ "number" ]))
        osConfig.device.monitors);
      workspaceOutputAssign =
        (lib.attrsets.foldlAttrs
          (acc: n: v:
            (builtins.map
              (x: {
                output = n;
                workspace = v.number + (builtins.toString x);
              })
              (builtins.genList (x: x + 1) 9)) ++ acc)
          [ ]
          osConfig.device.monitors);
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
        "${modifier}+F12" = "exec ${commands.screenshot}";
        "${modifier}+backslash" = "exec ${commands.editor}";
        "${modifier}+tab" = "exec ${commands.windows}";

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
