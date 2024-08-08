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
  #https://github.com/tree-sitter/tree-sitter/issues/3296
  tree-sitter = prev.tree-sitter.overrideAttrs (old: rec {
    pname = "tree-sitter";
    version = "0.22.2";
    src = prev.fetchFromGitHub {
      owner = "tree-sitter";
      repo = "tree-sitter";
      rev = "v${version}";
      hash = "sha256-RhM3SgsCb8eLs56cm8/Yo1ptNnFrR21FriHAlMdvdrU=";
    };
    cargoDeps = old.cargoDeps.overrideAttrs (prev.lib.const {
      name = "${pname}-vendor.tar.gz";
      inherit src;
      outputHash = "sha256-EcRYHEfLookHi/0xGVAWzypFZQjdKTkRYBw2h39YJLM=";
    });
  });

  ryzst = prev.ryzst // {
    overrides.emacs = epkgs: epkgs // {
      # add unpackaged emacs package
      souffle-ts-mode = prev.callPackage ../packages/souffle-ts-mode/package.nix {
        inherit (prev.pkgs) fetchFromGitHub;
        inherit (epkgs) trivialBuild;
      };
      #https://emacs-lsp.github.io/lsp-mode/page/performance/#use-plists-for-deserialization
      lsp-mode = epkgs.melpaPackages.lsp-mode.overrideAttrs
        (old: {
          env = {
            LSP_USE_PLISTS = "true";
          };
        });
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
