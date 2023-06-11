final: prev:
let
  nixpkgs = { rev, sha256 }:
    import
      (prev.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        inherit rev sha256;
      })
      {
        system = prev.system;
        config.allowUnfree = true;
        config.allowUnsupportedSystem = true;
      };
in
{
  inherit (nixpkgs {
    rev = "4de80d51aade7a45592b9802f44ed2d2233be3ea";
    sha256 = "sha256-EnjZbyBtp//YdFcX/w7191S/YV4fSaMX0bzy+DLuirE=";
  }) vscodium;
}
