{ self, system }:
let
  usernames-check-script = with self.inputs.nixpkgs.legacyPackages.${system};
    writeShellApplication {
      name = "usernames-check";
      runtimeInputs = [
        nix
      ];
      text = ''
        # TODO: don't use nix
        nix eval ${self}#lib --impure \
        --apply "lib: builtins.mapAttrs (n: v: lib.names.user.toUID n) (lib.getDirs ./idm/users)"
      '';
    };
  usernames-check = {
    enable = true;
    name = "Username check";
    entry = "${usernames-check-script}/bin/usernames-check";
    files = "idm/users";
    language = "system";
    pass_filenames = false;
  };
in
usernames-check
