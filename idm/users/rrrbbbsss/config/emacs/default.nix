{ pkgs, lib, ... }:
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

  # to make sure user env vars get loaded
  systemd.user.services.emacs.Service.ExecStart = lib.mkForce ''
    ${pkgs.zsh}/bin/zsh -l -c "${emacspkg}/bin/emacs --fg-daemon"
  '';


  programs.zsh.shellAliases = {
    "emacs" = "${emacspkg}/bin/emacsclient -c";
  };
}
