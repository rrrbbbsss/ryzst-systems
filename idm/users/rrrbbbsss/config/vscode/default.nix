{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    mutableExtensionsDir = false;
    package = pkgs.vscodium;
    userSettings = {
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nil";
      "nix.serverSettings" = {
        "nil" = {
          "formatting" = {
            "command" = [
              "nixpkgs-fmt"
            ];
          };
        };
      };
      "explorer.confirmDragAndDrop" = false;
      "terminal.integrated.sendKeybindingsToShell" = true;
    };
    extensions = with pkgs.vscode-marketplace; [
      # vim keys
      vscodevim.vim
      # dir env
      mkhl.direnv
      # nix
      jnoortheen.nix-ide
      # rust
      rust-lang.rust-analyzer
      tamasfe.even-better-toml
      # python
      ms-python.python
      # latex
      james-yu.latex-workshop
      #prolog
      arthurwang.vsc-prolog
      #org
      tootone.org-mode
    ];
  };
}
