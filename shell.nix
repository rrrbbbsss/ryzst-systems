{ pkgs, ... }:

with pkgs;
let
  nixBin =
    writeShellScriptBin "nix" ''
      ${nixFlakes}/bin/nix --option experimental-features "nix-command flakes" "$@"
    '';
in
mkShell {
  nativeBuildInputs = [
    nil
    nixpkgs-fmt
    direnv
    ryzst.cli
  ];
  shellHook = ''
    export FLAKE="$(pwd)"
    export PATH="${nixBin}/bin:$PATH"
  '';
}
