{ pkgs, ... }:
{
  programs.emacs = {
    enable = true;
    package = (pkgs.emacsWithPackagesFromUsePackage {
      package = pkgs.emacs-pgtk;
      config = ./init.el;
      defaultInitFile = true;
    });
  };
}
