{ self, system }:
let
  pre-commit-hooks = self.inputs.pre-commit-hooks;
in
{
  pre-commit-check = pre-commit-hooks.lib.${system}.run {
    src = ../.;
    hooks = {
      #format
      nixpkgs-fmt.enable = true;
      shfmt.enable = true;
    };
  };
}
