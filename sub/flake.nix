{
  description = "subflake";

  inputs = {
    ryzst.url = "path:../";

    pre-commit-hooks.url = "git+https://github.com/cachix/git-hooks.nix?shallow=1";
    pre-commit-hooks.inputs.nixpkgs.follows = "ryzst/nixpkgs";
    pre-commit-hooks.inputs.flake-compat.follows = "flake-compat";
    pre-commit-hooks.inputs.gitignore.follows = "gitignore";

    flake-compat.url = "git+https://github.com/edolstra/flake-compat?shallow=1";
    flake-compat.flake = false;

    gitignore.url = "git+https://github.com/hercules-ci/gitignore.nix?shallow=1";
    gitignore.inputs.nixpkgs.follows = "ryzst/nixpkgs";
  };

  outputs = { self, ... }: {

    inherit (self.inputs.ryzst)
      lib
      nixosModules
      overlays;

    systems = [
      { local = "x86_64-linux"; cross = null; }
      { local = "aarch64-linux"; cross = null; }
      {
        local = "x86_64-linux";
        cross = "aarch64-linux";
        native = pkgs: { inherit (pkgs) linuxKernel; };
      }
    ];

    instances = self.lib.mkInstances self {
      allowUnfree = true;
      allowUnsupportedSystem = true;
    };

    devShells = import ../shell.nix self;

    formatter = self.lib.mkSystems self (system:
      self.instances.${system.string}.nixpkgs-fmt);

    checks = import ../checks self;

    apps = import ../apps self;

    packages = import ../packages self;

    nixosConfigurations = import ../hosts self;

    hosts = builtins.mapAttrs
      (n: v: v.config.system.build.toplevel)
      self.nixosConfigurations;
  };
}
