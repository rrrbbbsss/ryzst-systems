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
      #https://github.com/cosmicexplorer/helm-rg/pull/33
      helm-rg = epkgs.melpaPackages.helm-rg.overrideAttrs
        (old: {
          patches = [
            (prev.fetchpatch {
              url = "https://github.com/cosmicexplorer/helm-rg/pull/33/commits/26725676b31e6e60b054b0ee1482be450cb826d7.patch";
              hash = "sha256-AGAvRzmWfBt+PcnKVaX4/N7jUELgDCQSXxi8pK88Bsg=";
            })
          ];
        });
    };
  };
}
