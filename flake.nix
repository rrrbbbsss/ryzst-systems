{
  description = "ryzst-systems: learning nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # use/follow flake-utils eventually
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
        };
      };

      nixosConfigurations = self.lib.mkHosts ./hosts;
      vms = self.lib.mkVMs ./hosts;
      images = self.lib.mkHosts ./images;
    };
}
