{ pkgs, config, ... }:
let
  colors = {
    bar = "#000000";
    background = "#1d1f21";
    border = "#3f4040";
    hover = "#292b2b";
  };
  launcher = "${pkgs.sway}/bin/swaymsg exec";
  bar = [
    {
      image = "${pkgs.firefox}/share/icons/hicolor/128x128/apps/firefox.png";
      exe = "${pkgs.firefox}/bin/firefox";
    }
    {
      image = "${pkgs.steam}/share/icons/hicolor/256x256/apps/steam.png";
      exe = "${pkgs.steam}/bin/steam";
    }
    {
      image = "${pkgs.spotify}/share/spotify/icons/spotify-linux-256.png";
      exe = "${pkgs.spotify}/bin/spotify";
    }
    {
      image = ./images/power.png;
      exe = "todo";
    }
  ];
  ewwDir = pkgs.stdenv.mkDerivation
    {
      name = "ewwDir";
      src = ./.;
      phases = [ "installPhase" ];
      installPhase = ''
        mkdir -p $out

        cat <<EOF > bar.json
        ${builtins.toJSON bar}
        EOF
        
        cat <<EOF > $out/vars.yuck
        (defvar launcher "${launcher}")
        (defvar icons $(${pkgs.jq}/bin/jq @json < bar.json))
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
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
