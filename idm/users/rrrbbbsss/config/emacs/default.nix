{ pkgs, lib, ... }:
let
  mkEmacsPackage = { emacs, config, packages }:
    (pkgs.emacsPackagesFor emacs).emacsWithPackages
      (epkgs: [
        (epkgs.trivialBuild {
          pname = "default-init-file";
          src = pkgs.writeText "default.el" (builtins.readFile config);
        })
      ] ++ (packages epkgs));

  emacspkg = mkEmacsPackage {
    emacs = pkgs.emacs-pgtk;
    config = ./init.el;
    packages = epkgs: with epkgs; [
      doom-themes
      evil
      avy
      vterm
      form-feed
      magit
      pinentry
      flycheck
      company
      helm
      helm-projectile
      helm-rg
      helm-descbinds
      helm-flyspell
      projectile
      direnv
      treemacs
      treemacs-evil
      doom-modeline
      nerd-icons
      org-bullets
      nix-mode
      nov
      beacon
    ];
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
    client.enable = true;
    startWithUserSession = "graphical";
  };

  # to make sure user env vars get loaded
  systemd.user.services.emacs.Service.ExecStart = lib.mkForce ''
    ${pkgs.zsh}/bin/zsh -l -c "${emacspkg}/bin/emacs --fg-daemon"
  '';

  programs.zsh = {
    #vterm directory tracking
    initExtra = ''
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
}
