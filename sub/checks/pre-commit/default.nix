self:
let
  inherit (self.inputs) pre-commit-hooks;
in
self.lib.mkSystems self (system:
let
  hostnames-check = import ./hostnames-check.nix { inherit self system; };
  usernames-check = import ./usernames-check.nix { inherit self system; };
in
{
  pre-commit-check = pre-commit-hooks.lib.${system.string}.run {
    src = ../.;
    hooks = {
      inherit hostnames-check usernames-check;
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
