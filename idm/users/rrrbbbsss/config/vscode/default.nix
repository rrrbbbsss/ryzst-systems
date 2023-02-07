{ pkgs, ... }:
{
    programs.vscode = {
      enable = true;
      #enableUpdateCheck = false;
      #enableExtensionUpdateCheck = false;
      package = pkgs.vscodium;
      extensions = [
        # vim keys
        pkgs.vscode-extensions.vscodevim.vim
        # dir env
        pkgs.vscode-extensions.mkhl.direnv
        # nix
        pkgs.vscode-extensions.jnoortheen.nix-ide
        # rust
        pkgs.vscode-extensions.matklad.rust-analyzer
        pkgs.vscode-extensions.tamasfe.even-better-toml
        # python
        pkgs.vscode-extensions.ms-python.python
        # org-mode
        #(import vscode-org-mode.nix)
        # will have to package myself...
      ];
    };
}