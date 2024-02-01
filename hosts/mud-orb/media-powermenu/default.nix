{ pkgs, ... }:
let
  colors = {
    bar = "#000000";
    background = "#1d1f21";
    border = "#3f4040";
    hover = "#292b2b";
    font = "#C5C8C6";
  };
  media-powermenuDir = pkgs.stdenv.mkDerivation {
    name = "media-powermenuDir";
    src = ./.;
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out

      install $src/style.css $out/style.css

      cat <<EOF > $out/colors.css
      @define-color bar ${colors.bar};
      @define-color background ${colors.background};
      @define-color border ${colors.border};
      @define-color hover ${colors.hover};
      @define-color font ${colors.font};
      EOF
    '';
  };
in
{
  programs.media-powermenu = {
    enable = true;
    configDir = media-powermenuDir;
  };
}
