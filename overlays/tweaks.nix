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

  # use /etc/pam_p11/<username> instead of home dir
  pam_p11 = prev.pam_p11.overrideAttrs (old: {
    patches = old.patches or [ ] ++ [ ./pam_p11.patch ];
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
    };
  };
}
