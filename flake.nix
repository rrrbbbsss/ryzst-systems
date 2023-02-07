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

      packages.${system} = with pkgs; {
        default = self.packages.${system}.cli;
        cli = callPackage ./packages/cli { };
        sabaki = callPackage ./packages/sabaki { };
        katrain = callPackage ./packages/katrain { };
        katago-model = callPackage ./packages/katago-model { };
        q5go = with libsForQt5; callPackage ./packages/q5go { };
        python-libs = with python3Packages; {
          kivy = callPackage ./packages/python-libs/kivy {
            inherit (pkgs) mesa;
            inherit (pkgs.darwin.apple_sdk.frameworks) ApplicationServices AVFoundation;
          };
          kivymd = callPackage ./packages/python-libs/kivymd { };
          ffpyplayer = callPackage ./packages/python-libs/ffpyplayer { };
        };
      };

      overlays = {
        default = final: prev: {
          ryzst = self.packages.${system};
        };
      };

      nixosConfigurations = {
        bed = nixpkgs.lib.nixosSystem {
          inherit system pkgs;
          modules = [
            ./hosts/bed
            ./hosts/bed/hardware.nix
            home-manager.nixosModule
            ./idm/users/rrrbbbsss
          ];
        };
      };

      vms = {
        bed = nixpkgs.lib.nixosSystem {
          inherit system pkgs;
          modules = [
            (nixpkgs + "/nixos/modules/virtualisation/qemu-vm.nix")
            ./hosts/bed
            ./hosts/bed/vm.nix
            home-manager.nixosModule
            ./idm/users/rrrbbbsss
          ];
        };
      };

      images = {
        live = nixpkgs.lib.nixosSystem {
          inherit system pkgs;
          modules = [
            (nixpkgs + "/nixos/modules/installer/cd-dvd/iso-image.nix")
            (nixpkgs + "/nixos/modules/profiles/all-hardware.nix")
            (nixpkgs + "/nixos/modules/profiles/base.nix")
            ./images/live
            home-manager.nixosModule
            ./idm/users/rrrbbbsss
          ];
        };
      };
    };
}
