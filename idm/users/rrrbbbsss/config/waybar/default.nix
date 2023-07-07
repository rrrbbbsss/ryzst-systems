{ ... }:
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        spacing = 0;
        margin-top = 0;
        margin-bottom = 0;
        modules-left = [
          "clock"
          "sway/mode"
        ];
        modules-center = [ "sway/workspaces" ];
        modules-right = [
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "disk"
          "temperature"
          "idle_inhibitor"
        ];
        "sway/mode" = {
          format = "{}";
        };
        "sway/scratchpad" = {
          format = "{icon} {count}";
          show-empty = false;
          format-icons = [ "" " " ];
          tooltip = true;
          tooltip-format = "{app}: {title}";
        };
        clock = {
          timezone = "America/Chicago";
          format = "{:%D %H:%M}";
          tooltip-format = "{calendar}";
          calendar = {
            mode = "month";
            on-scroll = 1;
            format = {
              today = "<b><u>{}</u></b>";
            };
          };
          actions = {
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };
        cpu = {
          format = "{usage:3}%  ";
          tooltip = true;
          states = {
            critical = 90;
          };
        };
        memory = {
          format = "{percentage:3}%  ";
          states = {
            critical = 90;
          };
        };
        disk = {
          format = "{percentage_used:3}%  ";
          states = {
            critical = 90;
          };
        };
        temperature = {
          critical-threshold = 80;
          format = "{temperatureC:2}°C {icon}";
          format-icons = [ "" "" "" ];
        };
        network = {
          format-wifi = "{essid} {signalStrength:3}%  ";
          format-ethernet = "{ipaddr}/{cidr} ";
          tooltip-format = "{ifname} via {gwaddr} ";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "Disconnected ⚠";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
        };
        pulseaudio = {
          format = "{volume:3}% {icon} {format_source}";
          format-bluetooth = "{volume:3}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = "{volume:3}% ";
          format-source-muted = " ";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
          on-click = "pavucontrol";
        };
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = " ";
            deactivated = " ";
          };
        };
      };
    };
    style = builtins.readFile ./style.css;
  };
}
