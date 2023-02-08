{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    autocd = true;
    defaultKeymap = "viins";
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    initExtra = ''
      stty -ixon
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      autoload -Uz vcs_info
      precmd() { vcs_info }
      zstyle ':vcs_info:git:*' formats '%K{#000000} %b %K{#4e4e4e} %k'
      function zle-keymap-select {
        VIMODE="''${''${KEYMAP/vicmd/$}/(main|viins)/>}"
        zle reset-prompt
      }
      zle -N zle-keymap-select
      setopt PROMPT_SUBST
      PSPACE='%K{#4e4e4e} %k'
      VIMODE='>'
      PROMPT='$PSPACE%(?.%K{green} %k.%K{red} %k)$PSPACE%K{#000000} %n $PSPACE%K{#000000} %m $PSPACE%K{#000000} %40<...<%~/%<< $PSPACE''${vcs_info_msg_0_}%k 
      $VIMODE '

      function prepend_sudo() {
        if [[ $BUFFER != "sudo "* ]]; then
          BUFFER="sudo $BUFFER"; CURSOR+=5
        fi
      }
      zle -N prepend_sudo
      bindkey -M vicmd "\C-s" prepend_sudo
    '';
    shellAliases = {
      "-s pdf" = "zathura --fork";
      "mpp" = "mpv --shuffle --loop-playlist=inf /nfs/Music";
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
}
