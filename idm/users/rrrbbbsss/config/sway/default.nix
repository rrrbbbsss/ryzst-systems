{ pkgs, ... }:
{
  home.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
    NIXOS_OZONE_WL = "1";
  };

  home.packages = with pkgs; [
    xorg.xwininfo
    swaylock
    swayidle
    swaybg
    waybar
    wl-clipboard
    wlr-randr
    mako
    fuzzel
    #do i really need all this stuff?
    glib
    gnome.adwaita-icon-theme
    gsettings-desktop-schemas
    glxinfo
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
    events = [
      { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock"; }
      { event = "lock"; command = "${pkgs.swaylock}/bin/swaylock"; }
    ];
  };

  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    wrapperFeatures.gtk = true;
    config = rec {
      modifier = "Mod4";
      terminal = "alacritty";
      menu = "fuzzel --text-color=ae7eedff --background-color=180d26ff --border-color=ae7eedff --selection-color=ae7eedff --selection-text-color=180d26ff --border-width=3";
      bars = [{
        fonts.size = 15.0;
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
        # trackball
        "1149:32792:Kensington_Expert_Wireless_TB_Mouse" = {
          scroll_button = "BTN_SIDE";
          scroll_method = "on_button_down";
          natural_scroll = "enabled";
        };
        # trackpoint
        "6127:24814:Lenovo_TrackPoint_Keyboard_II_Mouse" = {
          natural_scroll = "disabled";
          accel_profile = "adaptive";
          pointer_accel = "0.75";
        };
      };
      output = {
        "*" = { bg = "#180d26 solid_color"; };
        "DP-1" = { mode = "3440x1440@144Hz"; };
      };
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
      };
      floating = {
        criteria = [{ app_id = "SWAYFLOAT"; }];
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
        "${modifier}+Shift+1" = "move container to workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace number 9";
        #execute
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+d" = "exec ${menu}";
        "${modifier}+p" = "exec ${pkgs.alacritty}/bin/alacritty --title 'FZF-Pass' --class 'SWAYFLOAT' -e ${pkgs.ryzst.fzf-pass}/bin/fzf-pass";
        "${modifier}+n" = "exec ${pkgs.alacritty}/bin/alacritty --title 'FZF-Wifi' --class 'SWAYFLOAT' -e bash -c '${pkgs.ryzst.fzf-wifi}/bin/fzf-wifi && sleep 1'";
        "${modifier}+F12" = "exec ${pkgs.flameshot}/bin/flameshot gui";

        #scratchpad
        "${modifier}+Shift+Backspace" = "move scratchpad";
        "${modifier}+Backspace" = "scratchpad show";
        #sway
        "${modifier}+Shift+c" = "reload";
        "${modifier}+Shift+e" = "exec swaynag -t warning -m 'Do you really want to exit sway?' -b 'Yes' 'swaymsg exit'";
        #modes
        "${modifier}+r" = "mode resize";
        "${modifier}+Shift+Escape" = "mode vm";

      };

    };
  };
}
