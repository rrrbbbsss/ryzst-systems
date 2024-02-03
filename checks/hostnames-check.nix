{ self, system }:
let
  hostnames-check-script = with self.inputs.nixpkgs.legacyPackages.${system};
    writeShellApplication {
      name = "hostnames-check";
      runtimeInputs = [
        nix
      ];
      text = ''
        # TODO: don't use nix
        nix eval ${self}#lib --impure \
        --apply "lib: builtins.mapAttrs (n: v: lib.names.host.toIP n) (lib.getDirs ./hosts)"
      '';
    };
  hostnames-check = {
    enable = true;
    name = "Hostname check";
    entry = "${hostnames-check-script}/bin/hostnames-check";
    files = "hosts/";
    language = "system";
    pass_filenames = false;
  };
in
hostnames-check
