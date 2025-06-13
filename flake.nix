{
  description = "ryzst-systems: learning nix";
  # https://dl.acm.org/doi/pdf/10.1145/232627.232653
  # https://en.wikipedia.org/wiki/Dunbar%27s_number

  # TODO: would like to move most of these to subflake
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

    # weird thought:
    # could nixpkgs lib be a subflake?
    # (no clue of feasibility.)

    lib = import ./lib self;

    # TODO: clean this up.
    overlays = import ./overlays self;

    # TODO: make this more consumable
    nixosModules = import ./modules self;

    # TODO: make this more consumable
    homeManagerModules.default = import ./modules/home self;

  };
}
