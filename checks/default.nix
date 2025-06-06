{ self }:
let
  inherit (self) systems;
  inherit (self.inputs) pre-commit-hooks nixpkgs;
  #hostnames-check = import ./hostnames-check.nix { inherit self system; };
  #usernames-check = import ./usernames-check.nix { inherit self system; };
in
nixpkgs.lib.genAttrs systems (system:
{
  pre-commit-check = pre-commit-hooks.lib.${system}.run {
    src = ../.;
    hooks = {
      # TODO: re-enable
      #inherit hostnames-check usernames-check;
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
})
