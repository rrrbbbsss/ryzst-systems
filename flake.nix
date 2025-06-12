{
  description = "ryzst-systems: learning nix";
  # https://dl.acm.org/doi/pdf/10.1145/232627.232653
  # https://en.wikipedia.org/wiki/Dunbar%27s_number

  inputs = {
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixos-25.05";
    nixpkgs-stable.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixos-25.05";

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

    hosts.url = "git+https://github.com/StevenBlack/hosts?shallow=1";
    hosts.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, ... }: {

    systems = [
      { local = "x86_64-linux"; cross = null; }
      { local = "aarch64-linux"; cross = null; }
      {
        local = "x86_64-linux";
        cross = "aarch64-linux";
        # cross yaml-merge makes me cross-eyed.
        native = pkgs: { inherit (pkgs) linuxKernel yaml-merge; };
      }
    ];

    instances = self.lib.mkInstances {
      allowUnfree = true;
      allowUnsupportedSystem = true;
    };

    lib = import ./lib self;

    overlays = import ./overlays self;

    nixosConfigurations = import ./hosts self;

    nixosModules = import ./modules self;

    homeManagerModules.default = import ./modules/home self;

    hosts = builtins.mapAttrs
      (n: v: v.config.system.build.toplevel)
      self.nixosConfigurations;

    templates = import ./templates self;
  };
}
