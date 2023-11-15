{ pkgs, lib, ... }:
let
  emacspkg = pkgs.emacsWithPackagesFromUsePackage {
    package = pkgs.emacs-pgtk;
    config = ./init.el;
    defaultInitFile = true;
    extraEmacsPackages = epkgs: with epkgs; [
      treesit-grammars.with-all-grammars
    ];
    override = pkgs.ryzst.overrides.emacs;
  };
in
{
  programs.emacs = {
    enable = true;
    package = emacspkg;
  };

  services.emacs = {
    enable = true;
    package = emacspkg;
    defaultEditor = true;
    client.enable = true;
    startWithUserSession = "graphical";
  };

  # to make sure user env vars get loaded
  systemd.user.services.emacs.Service.ExecStart = lib.mkForce ''
    ${pkgs.zsh}/bin/zsh -l -c "${emacspkg}/bin/emacs --fg-daemon"
  '';

  programs.zsh = {
    #vterm directory tracking
    initExtra = lib.mkAfter ''
      vterm_printf() {
        if [ -n "$TMUX" ] && { [ "''${TERM%%-*}" = "tmux" ] || [ "''${TERM%%-*}" = "screen" ] ; }  then
            printf "\ePtmux;\e\e]%s\007\e\\" "$1"
        elif [ "''${TERM%%-*}" = "screen" ]; then
            printf "\eP\e]%s\007\e\\" "$1"
        else
            printf "\e]%s\e\\" "$1"
        fi
      }
      vterm_prompt_end() {
        vterm_printf "51;A$(whoami)@$(hostname):$(pwd)"
      }
      setopt PROMPT_SUBST
      PROMPT=$PROMPT'%{$(vterm_prompt_end)%}'
    '';
    shellAliases = {
      "emacs" = "${emacspkg}/bin/emacsclient -c";
    };
  };

  xdg.mimeApps =
    let
      app = "emacsclient.desktop";
      mimeapps = {
        "text/plain" = [ app ];
      };
    in
    {
      enable = true;
      associations.added = mimeapps;
      defaultApplications = mimeapps;
    };

  home.packages = with pkgs; [
    #treemacs
    python3
    #formatters
    taplo-lsp
    nodePackages.prettier
    nodePackages.vscode-json-languageserver
    yaml-language-server
  ];
}
