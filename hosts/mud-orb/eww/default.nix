{ pkgs, config, lib, ... }:
let
  colors = {
    bar = "#000000";
    background = "#1d1f21";
    border = "#3f4040";
    hover = "#292b2b";
    font = "#C5C8C6";
  };
  bar = [
    {
      name = "firefox";
      criteria = [{ app_id = "firefox"; }];
      image = "${pkgs.firefox}/share/icons/hicolor/128x128/apps/firefox.png";
      exe = "${pkgs.firefox}/bin/firefox";
    }
    {
      name = "steam";
      criteria = [{ class = "Steam"; }];
      image = "${pkgs.steam}/share/icons/hicolor/256x256/apps/steam.png";
      exe = "${pkgs.steam}/bin/steam";
    }
    {
      name = "spotify";
      criteria = [{ class = "Spotify"; }];
      image = "${pkgs.spotify}/share/spotify/icons/spotify-linux-256.png";
      exe = "${pkgs.spotify}/bin/spotify";
    }
    {
      name = "media-powermenu";
      criteria = [{ app_id = "net.ryzst.media-powermenu"; }];
      image = "${pkgs.ryzst.media-powermenu}/share/icons/power.png";
      exe = "${pkgs.ryzst.media-powermenu}/bin/media-powermenu";
    }
  ];
  assignments = lib.lists.foldr
    (x: acc: { "${x.name}" = x.criteria; } // acc)
    { }
    bar;
  launcher = "${pkgs.writeShellApplication {
    name = "launcher";
    runtimeInputs = [ pkgs.systemd config.wayland.windowManager.sway.package ];
    text = ''
      swaymsg workspace "$1"
      systemd-run --user --unit "$1" "$2"
    '';
  }}/bin/launcher";
  killer = "${pkgs.writeShellApplication {
    name = "killer";
    runtimeInputs = [ pkgs.systemd ];
    text = ''
      systemctl --user stop "$1"
    '';
  }}/bin/killer";
  ewwDir = pkgs.stdenv.mkDerivation
    {
      name = "ewwDir";
      src = ./.;
      phases = [ "installPhase" ];
      installPhase = ''
        mkdir -p $out

        cat <<EOF > $out/bar.json
        ${builtins.toJSON bar}
        EOF
        
        cat <<EOF > $out/vars.yuck
        (defvar launcher "${launcher}")
        (defvar killer "${killer}")
        (defvar icons $(${pkgs.jq}/bin/jq @json < $out/bar.json))
        EOF
        
        cat <<\EOF > $out/colors.scss
        $bar: ${colors.bar};
        $background: ${colors.background};
        $border: ${colors.border};
        $hover: ${colors.hover};
        EOF

        cp -r $src/* $out
      '';
    };
in
{
  programs.eww = {
    enable = true;
    package = pkgs.eww-wayland;
    configDir = ewwDir;
  };

  systemd.user.services.eww = {
    Unit = {
      Description = "ElKowars wacky widgets";
      Documentation = "https://elkowar.github.io/eww/eww.html";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session-pre.target" ];
    };
    Service = {
      Environment = [
        "GTK_THEME=Adwaita:dark"
      ];
      ExecStart = "${config.programs.eww.package}/bin/eww --no-daemonize daemon";
      ExecReload = "${config.programs.eww.package}/bin/eww reload";
      Restart = "on-failure";
      KillMode = "mixed";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  systemd.user.services.bar = {
    Unit = {
      Description = "Bar";
      PartOf = [ "graphical-session.target" ];
      After = [ "eww.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${config.programs.eww.package}/bin/eww open bar";
      Restart = "on-failure";
      RestartSec = 1;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  wayland.windowManager.sway.config.assigns = assignments;
}
