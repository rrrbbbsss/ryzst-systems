self:
let
  inherit (self) instances;
in
self.lib.mkSystems (system:
{
  default = with instances.${system.string};
    mkShell {
      inherit (self.checks.${system.string}.pre-commit-check) shellHook;
      nativeBuildInputs = [
        nil
        nixpkgs-fmt
        direnv
        statix
        shellcheck
      ];
    };
})
