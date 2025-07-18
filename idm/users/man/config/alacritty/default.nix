{ pkgs, ... }:
let
  font = "DejaVu Sans M Nerd Font";
in
{
  programs.alacritty = {
    enable = true;
    settings = {
      general.import = [ "${pkgs.alacritty-theme}/share/alacritty-theme/alacritty_0_12.toml" ];
      env.TERM = "alacritty";
      window = {
        decorations = "full";
        title = "Alacritty";
        dynamic_title = true;
        class = {
          instance = "Alacritty";
          general = "Alacritty";
        };
      };
      font = {
        normal = {
          family = font;
          style = "regular";
        };
        bold = {
          family = font;
          style = "regular";
        };
        italic = {
          family = font;
          style = "regular";
        };
        bold_italic = {
          family = font;
          style = "regular";
        };
        size = 12.00;
      };
    };
  };
}
