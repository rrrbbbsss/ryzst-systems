{
  description = "ryzst-systems: learning nix";
  # https://dl.acm.org/doi/pdf/10.1145/232627.232653
  # https://en.wikipedia.org/wiki/Dunbar%27s_number

  # TODO: would like to move most of these to subflake
  inputs = {
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixos-25.05";

    home-manager.url = "git+https://github.com/nix-community/home-manager/?shallow=1&ref=release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "git+https://github.com/nix-community/disko?shallow=1";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    firefox-addons.url = "git+https://gitlab.com/rycee/nur-expressions?shallow=1&dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";

    emacs-overlay.url = "git+https://github.com/nix-community/emacs-overlay?shallow=1";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.inputs.nixpkgs-stable.follows = "nixpkgs";

    nix-index-database.url = "git+https://github.com/nix-community/nix-index-database?shallow=1";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    hosts.url = "git+https://github.com/StevenBlack/hosts?shallow=1";
    hosts.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, ... }: {

    lib = import ./lib self;

    # NOTE: go use nixpkgs.
    overlays = import ./overlays self;

    # NOTE: go use nixpkgs.
    nixosModules = import ./modules/nixos self;

    # NOTE: go use homeManager.
    homeManagerModules = import ./modules/home self;

    # TODO: clean this up, and maybe not expose
    # (keep in subflake?)...
    settingsModules = import ./modules self;

    # TODO: might move to subflake...
    domain = import ./domain self;
  };
}
