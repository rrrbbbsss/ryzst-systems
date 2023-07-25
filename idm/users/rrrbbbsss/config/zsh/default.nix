{ config, pkgs, ... }:
let
  username = config.device.user;
in
{
  users.users.${username}.shell = pkgs.zsh;
  programs.zsh.enable = true;
  environment.pathsToLink = [ "/share/zsh" ];

  home-manager.users.${username} = { pkgs, ... }:
    {
      programs.zsh = {
        enable = true;
        autocd = true;
        defaultKeymap = "viins";
        enableCompletion = true;
        syntaxHighlighting.enable = true;
        dotDir = ".config/zsh";
        initExtra = ''
          stty -ixon
          ZVM_INIT_MODE=sourcing
          source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
          source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
          autoload -Uz vcs_info
          precmd() { vcs_info }
          zstyle ':vcs_info:git:*' formats '%K{#000000} %b %K{#4e4e4e} %k'
          function zle-keymap-select {
            VIMODE="''${''${KEYMAP/vicmd/$}/(main|viins)/>}"
            zle reset-prompt
          }
          function get_pwd() {
            tmp="''${PWD/$HOME/~}"
            echo "''${tmp%/}/"
          }
          zle -N zle-keymap-select
          setopt PROMPT_SUBST
          PSPACE='%K{#4e4e4e} %k'
          VIMODE='>'
          PROMPT='$PSPACE%(?.%K{green} %k.%K{red} %k)$PSPACE%K{#000000} %n $PSPACE%K{#000000} %m $PSPACE%K{#000000} %40<...<$(get_pwd)%<< $PSPACE''${vcs_info_msg_0_}%k 
          $VIMODE '

          function toggle_sudo() {
            if [[ $BUFFER == "sudo "* ]]; then
              LBUFFER="''${LBUFFER#sudo }"
            else
              LBUFFER="sudo $LBUFFER"
            fi
          }
          zle -N toggle_sudo
          bindkey -M vicmd "\C-s" toggle_sudo
          bindkey -M viins "\C-s" toggle_sudo
          bindkey -M viins "\C-r" fzf-history-widget

          function followlink() {
            ${pkgs.coreutils}/bin/readlink -f $(which "$1")
          }
        '';
        shellAliases = {
          "open" = "${pkgs.util-linux}/bin/setsid &>/dev/null -f ${pkgs.xdg-utils}/bin/xdg-open";
        };

      };

      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
      };

      home.packages = with pkgs; [
        zsh-completions
        nix-zsh-completions
      ];
    };
}
