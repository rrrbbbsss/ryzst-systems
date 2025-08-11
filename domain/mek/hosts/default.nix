self:
let
  inherit (self.inputs.nixpkgs.lib) substring;
  # TODO: clean up
  hash = builtins.hashString "sha256" "ryzst.net";
  subnet = "fd${substring 0 2 hash}:${substring 2 4 hash}:${substring 4 4 hash}::/48";

  mkHosts = dir: with builtins;
    mapAttrs
      (name: path: {
        module = path;
        hardware = "${path}/hardware.nix";
        ip = self.lib.names.host.toIP name subnet;
      } // fromJSON (readFile "${path}/registration.json"))

      (self.lib.getDirs dir);
in
mkHosts ./.
