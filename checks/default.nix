{ self, system }:
let
  inherit (self.inputs) pre-commit-hooks;
in
{
  pre-commit-check = pre-commit-hooks.lib.${system}.run {
    src = ../.;
    hooks = {
      #format
      nixpkgs-fmt.enable = true;
      shfmt.enable = true;
      #lint
      statix.enable = true;
      shellcheck = {
        enable = true;
        types_or = [ "shell" ];
      };
    };
  };
}
