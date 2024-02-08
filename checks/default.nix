{ self, system }:
let
  inherit (self.inputs) pre-commit-hooks;
  hostnames-check = import ./hostnames-check.nix { inherit self system; };
in
{
  pre-commit-check = pre-commit-hooks.lib.${system}.run {
    src = ../.;
    hooks = {
      # TODO: re-enable
      #inherit hostnames-check;
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
