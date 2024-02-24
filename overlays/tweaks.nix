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
  ryzst = prev.ryzst // {
    overrides.emacs = epkgs: epkgs // {
      # add unpackaged emacs package
      souffle-ts-mode = prev.callPackage ../packages/souffle-ts-mode {
        inherit (prev.pkgs) fetchFromGitHub;
        inherit (epkgs) trivialBuild;
      };
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
      #https://github.com/cosmicexplorer/helm-rg/pull/33
      helm-rg = epkgs.melpaPackages.helm-rg.overrideAttrs
        (old: {
          patches = [
            (prev.fetchpatch {
              url = "https://github.com/cosmicexplorer/helm-rg/pull/33.patch";
              sha256 = "sha256-AGAvRzmWfBt+PcnKVaX4/N7jUELgDCQSXxi8pK88Bsg=";
            })
          ];
        });
    };
  };
}
