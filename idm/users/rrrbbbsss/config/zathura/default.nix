{ pkgs, ... }:
let
  #todo: switch to stylix
  colorscheme = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/HaoZeke/base16-zathura/9f148b4001dc67d399e645919225943d47e50125/build_schemes/colors/base16-tomorrow-night.config";
    sha256 = "1rkjl93clq870r3vhi6a89rjl5fq1fdq57n88mnqd428w20g0dn5";
  };
in
{
  programs.zathura = {
    enable = true;
    options = {
      recolor = true;
      guioptions = "";
      adjust-open = "best-fit";
    };
    extraConfig = ''
      include ${colorscheme}
    '';
  };

  xdg.mimeApps =
    let
      app = "org.pwmt.zathura.desktop";
      mimeapps = {
        "image/vnd.djvu" = [ app ];
        "application/pdf" = [ app ];
        "application/postscript" = [ app ];
      };
    in
    {
      enable = true;
      associations.added = mimeapps;
      defaultApplications = mimeapps;
    };
}
