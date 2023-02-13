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
    };
    extensions = with pkgs.vscode-extensions; [
      # vim keys
      vscodevim.vim
      # dir env
      mkhl.direnv
      # nix
      jnoortheen.nix-ide
      # rust
      matklad.rust-analyzer
      tamasfe.even-better-toml
      # python
      ms-python.python
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      # prolog
      {
        publisher = "arthurwang";
        name = "vsc-prolog";
        version = "0.8.23";
        sha256 = "sha256-Da2dCpruVqzP3g1hH0+TyvvEa1wEwGXgvcmIq9B/2cQ=";
      }
      # org
      {
        publisher = "tootone";
        name = "org-mode";
        version = "0.5.0";
        sha256 = "sha256-vXwo3oFLwK/wY7XEph9lGvXYIxjZsxeIE4TVAROmV2o=";
      }
    ];
  };
}
