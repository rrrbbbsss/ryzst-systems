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

  outputs = { self, nixpkgs, home-manager, ... }:
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

      lib = import ./lib { inherit nixpkgs pkgs system home-manager; };

      packages.${system} = import ./packages { inherit pkgs; };

      overlays = {
        default = final: prev: {
          ryzst = self.packages.${system};
          firefox-addons = self.inputs.firefox-addons.packages.${system};
        };
      };

      nixosConfigurations = self.lib.mkHosts ./hosts;
      vms = self.lib.mkVMs ./hosts;
      images = self.lib.mkHosts ./images;
    };
}
