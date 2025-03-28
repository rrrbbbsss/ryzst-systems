{
  description = "ryzst-systems: learning nix";

  inputs = {
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixos-24.11";
    nixpkgs-stable.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixos-24.11";

    flake-utils.url = "git+https://github.com/numtide/flake-utils?shallow=1";

    flake-compat.url = "git+https://github.com/edolstra/flake-compat?shallow=1";
    flake-compat.flake = false;

    impermanence.url = "git+https://github.com/nix-community/impermanence?shallow=1";

    home-manager.url = "git+https://github.com/nix-community/home-manager/?shallow=1&ref=release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "git+https://github.com/nix-community/disko?shallow=1";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    firefox-addons.url = "git+https://gitlab.com/rycee/nur-expressions?shallow=1&dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";
    firefox-addons.inputs.flake-utils.follows = "flake-utils";

    emacs-overlay.url = "git+https://github.com/nix-community/emacs-overlay?shallow=1";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.inputs.nixpkgs-stable.follows = "nixpkgs-stable";

    nix-index-database.url = "git+https://github.com/nix-community/nix-index-database?shallow=1";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    pre-commit-hooks.url = "git+https://github.com/cachix/git-hooks.nix?shallow=1";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
    pre-commit-hooks.inputs.flake-compat.follows = "flake-compat";

    nixos-generators.url = "git+https://github.com/nix-community/nixos-generators?shallow=1";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    hosts.url = "git+https://github.com/StevenBlack/hosts?shallow=1";
    hosts.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    {
      lib = import ./lib { inherit self; };

      overlays = import ./overlays { inherit self; };

      nixosConfigurations = import ./hosts { inherit self; };

      nixosModules = import ./modules { inherit self; };

      homeManagerModules.default = import ./modules/home { inherit self; };

      hosts = builtins.mapAttrs
        (n: v: v.config.system.build.toplevel)
        self.nixosConfigurations;

      templates = import ./templates { inherit self; };
    } //
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ]
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ self.overlays.default ];
          };
        in
        {
          devShells.default = import ./shell.nix { inherit self system pkgs; };

          checks = import ./checks { inherit self system; };

          formatter = pkgs.nixpkgs-fmt;

          apps = import ./apps { inherit pkgs; };

          packages = import ./packages {
            inherit pkgs system self;
            inherit (self) lib;
          };
        }
      );
}
