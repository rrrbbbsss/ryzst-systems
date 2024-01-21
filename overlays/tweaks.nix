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
        inherit (prev) system;
        inherit (prev.config) allowUnfree allowUnsupportedSystem;
      };
in
{
  #https://github.com/NixOS/nixpkgs/issues/281272
  inherit (nixpkgs {
    rev = "ac72b47ca1aed04d2e79dae839e34322a1634d9f";
    sha256 = "sha256-d7rKs0LTxpKFL4D9jNh6NWFkOshTYlzDnC7Mr3t+Zak=";
  }) j4-dmenu-desktop;

  ryzst = prev.ryzst // {
    overrides.emacs = epkgs: epkgs // {
      #https://github.com/nix-community/emacs-overlay/issues/384
      geiser = epkgs.melpaPackages.geiser.overrideAttrs
        (old: {
          src = prev.fetchFromGitLab {
            owner = "emacs-geiser";
            repo = "geiser";
            rev = "4f305d3a7823c69455aad9088789afef73477c7a";
            hash = "sha256-IGIAY9IXLjdLaY9Vm+5rLionTeaZPMn+eKgo67pDPKo=";
          };
        });
    };
  };
}
