{
  description = "ryzst-systems: learning nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
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
  };

  outputs = { self, nixpkgs, flake-utils, nix-vscode-extensions, ... }:
    {
      lib = import ./lib { inherit self; };

      overlays = {
        default = final: prev: {
          ryzst = self.packages.${prev.system};
          firefox-addons = self.inputs.firefox-addons.packages.${prev.system};
          lib = prev.lib // { ryzst = self.lib; };
        };
      };

      nixosConfigurations = self.lib.mkHosts ./hosts;

      templates = self.lib.mkTemplates ./templates;
    } //
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ]
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            config.allowUnsupportedSystem = true;
            overlays = [ self.overlays.default nix-vscode-extensions.overlays.default ];
          };
        in
        {
          devShells.default = import ./shell.nix { inherit pkgs; };

          checks = self.lib.mkChecks { inherit system; };

          packages = import ./packages { inherit pkgs system; lib = self.lib; };
        }
      );
}
