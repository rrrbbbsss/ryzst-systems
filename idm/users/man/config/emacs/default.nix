{ pkgs, lib, ... }:
let
  emacspkg = pkgs.emacsWithPackagesFromUsePackage {
    package = pkgs.emacs-pgtk;
    config = ./init.el;
    defaultInitFile = true;
    extraEmacsPackages = epkgs: with epkgs; [
      (treesit-grammars.with-grammars (p:
        (builtins.attrValues p) ++ [ pkgs.ryzst.souffle-treesitter ]))
    ];
    override = epkgs: epkgs // {
      inherit (pkgs.ryzst) souffle-ts-mode;

      #https://emacs-lsp.github.io/lsp-mode/page/performance/#use-plists-for-deserialization
      lsp-mode = epkgs.melpaPackages.lsp-mode.overrideAttrs
        (old: {
          env = {
            LSP_USE_PLISTS = "true";
          };
        });
    };
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
    initContent = lib.mkAfter ''
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

      # https://github.com/akermu/emacs-libvterm/issues/745
      if [[ "$INSIDE_EMACS" ]]; then
         export PAGER=less
      fi
    '';
    shellAliases = {
      "emacs" = "${emacspkg}/bin/emacsclient -c";
    };
  };
  home.sessionVariables = {
    LSP_USE_PLISTS = "true";
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

  # ispell-word-list
  xdg.dataFile."emacs/wordlist.txt" = {
    source = pkgs.ryzst.wordlist;
  };

  home.packages = with pkgs; [
    rg
    #treemacs
    python3
    #formatters
    black
    taplo-lsp
    nodePackages.prettier
    efmt
    #lsp
    nodePackages.vscode-json-languageserver
    yaml-language-server
    pyright
    ryzst.souffle-lsp-plugin
    erlang-ls
    emacs-lsp-booster
  ];
}
