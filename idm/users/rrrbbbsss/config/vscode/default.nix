{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
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
      #https://github.com/nix-community/nix-vscode-extensions/issues/5
      pkgs.vscode-extensions.matklad.rust-analyzer
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
