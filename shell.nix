{ pkgs, ryzst, ... }:

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
    ryzst.apps
  ];
  shellHook = ''
    export PATH="${nixBin}/bin:$PATH"
    ${git}/bin/git config --local core.hooksPath $PWD/.githooks
  '';
}
