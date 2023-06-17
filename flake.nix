{
  description = "ryzst-systems: learning nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    impermanence.url = "github:nix-community/impermanence";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    disko = {
      url = "github:nix-community/disko";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , ...
    }:
    {
      lib = import ./lib { inherit self; };

      overlays = import ./overlays { inherit self; };

      nixosConfigurations = self.lib.mkHosts ./hosts;

      templates = self.lib.mkTemplates ./templates;
    } //
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ]
      (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        ryzst = self.packages.${system};
      in
      {
        devShells.default = import ./shell.nix { inherit pkgs ryzst; };

        checks = self.lib.mkChecks { inherit system; };

        formatter = pkgs.nixpkgs-fmt;

        packages = import ./packages { inherit pkgs ryzst system; lib = self.lib; };
      }
      );
}
