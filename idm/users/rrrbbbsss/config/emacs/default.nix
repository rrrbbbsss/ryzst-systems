{ pkgs, config, ... }:
let
  emacspkg = (pkgs.emacsWithPackagesFromUsePackage {
    package = pkgs.emacs-pgtk;
    config = ./init.el;
    defaultInitFile = true;
  });
in
{
  programs.emacs = {
    enable = true;
    package = emacspkg;
  };

  services.emacs = {
    enable = true;
    package = emacspkg;
    client.enable = true;
    startWithUserSession = "graphical";
  };

  #needed for emacs daemon to launch with wayland
  systemd.user.services.emacs.Unit.Environemnt = "GDK_BACKEND=wayland";

  programs.zsh.shellAliases = {
    "emacs" = "${emacspkg}/bin/emacsclient -c";
  };
}
