{ pkgs, ... }:
{
  programs.zathura = {
    enable = true;
    options = {
      recolor = true;
      guioptions = "";
      adjust-open = "best-fit";
    };
    extraConfig = ''
      include ${pkgs.ryzst.catppuccin-zathura}/catppuccin-mocha
    '';
  };
}
