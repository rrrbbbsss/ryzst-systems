{
  description = "ryzst-systems: learning nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "flake-utils";
      };
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ self.overlays.default ];
      };
    in
    {
      devShells.${system}.default = import ./shell.nix { inherit pkgs; };

      lib = import ./lib { inherit pkgs system self; };

      checks.${system} = self.lib.mkChecks {};

      packages.${system} = import ./packages { inherit pkgs; lib = self.lib; };

      overlays = {
        default = final: prev: {
          ryzst = self.packages.${system};
          firefox-addons = self.inputs.firefox-addons.packages.${system};
          lib = prev.lib // { ryzst = self.lib; };
        };
      };

      nixosConfigurations = self.lib.mkHosts ./hosts;

      templates = self.lib.mkTemplates ./templates;
    };
}
