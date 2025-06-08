{
  description = "ryzst-systems: learning nix";
  # https://dl.acm.org/doi/pdf/10.1145/232627.232653

  inputs = {
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixos-25.05";
    nixpkgs-stable.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixos-25.05";

    flake-compat.url = "git+https://github.com/edolstra/flake-compat?shallow=1";
    flake-compat.flake = false;

    impermanence.url = "git+https://github.com/nix-community/impermanence?shallow=1";

    home-manager.url = "git+https://github.com/nix-community/home-manager/?shallow=1&ref=release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "git+https://github.com/nix-community/disko?shallow=1";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    firefox-addons.url = "git+https://gitlab.com/rycee/nur-expressions?shallow=1&dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";

    emacs-overlay.url = "git+https://github.com/nix-community/emacs-overlay?shallow=1";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.inputs.nixpkgs-stable.follows = "nixpkgs-stable";

    nix-index-database.url = "git+https://github.com/nix-community/nix-index-database?shallow=1";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    pre-commit-hooks.url = "git+https://github.com/cachix/git-hooks.nix?shallow=1";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
    pre-commit-hooks.inputs.flake-compat.follows = "flake-compat";
    pre-commit-hooks.inputs.gitignore.follows = "gitignore";

    gitignore.url = "git+https://github.com/hercules-ci/gitignore.nix?shallow=1";
    gitignore.inputs.nixpkgs.follows = "nixpkgs";

    hosts.url = "git+https://github.com/StevenBlack/hosts?shallow=1";
    hosts.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }: {

    # ignore schema and experiment with cross-compilation:
    systems = [
      { local = "x86_64-linux"; cross = null; }
      { local = "aarch64-linux"; cross = null; }
      { local = "x86_64-linux"; cross = "aarch64-linux"; native = true; }
    ];

    instances = self.lib.mkSystems (system:
      # TODO: clean this up.
      let
        native = self.instances.${system.cross};
        native-overlay =
          if system.native
          then [
            (final: prev: {
              inherit (native)
                linuxKernel
                qemu;
            })
          ]
          else [ ];
      in
      import nixpkgs {
        config.allowUnfree = true;
        config.allowUnsupportedSystem = true;
        overlays = native-overlay ++ [ self.overlays.default ];
        localSystem = system.local;
        crossSystem = system.cross;
      });

    lib = import ./lib { inherit self; };

    overlays = import ./overlays { inherit self; };

    nixosConfigurations = import ./hosts { inherit self; };

    nixosModules = import ./modules { inherit self; };

    homeManagerModules.default = import ./modules/home { inherit self; };

    hosts = builtins.mapAttrs
      (n: v: v.config.system.build.toplevel)
      self.nixosConfigurations;

    templates = import ./templates { inherit self; };

    devShells = import ./shell.nix { inherit self; };

    formatter = self.lib.mkSystems (system:
      self.instances.${system.string}.nixpkgs-fmt);

    checks = import ./checks { inherit self; };

    apps = import ./apps { inherit self; };

    packages = import ./packages { inherit self; };
  };
}
