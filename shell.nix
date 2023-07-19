{ self, system, pkgs, ryzst, ... }:

with pkgs;
mkShell {
  inherit (self.checks.${system}.pre-commit-check) shellHook;
  nativeBuildInputs = [
    nil
    nixpkgs-fmt
    direnv
    ryzst.apps
  ];
}
