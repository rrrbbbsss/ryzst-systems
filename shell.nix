{ self }:
let
  inherit (self) instances systems;
  inherit (self.inputs) nixpkgs;
in
nixpkgs.lib.genAttrs systems (system:
{
  default = with instances.${system};
    mkShell {
      inherit (self.checks.${system}.pre-commit-check) shellHook;
      nativeBuildInputs = [
        nil
        nixpkgs-fmt
        direnv
        statix
        shellcheck
      ];
    };
})
