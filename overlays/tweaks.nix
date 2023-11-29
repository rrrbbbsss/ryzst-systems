final: prev:
{
  ryzst = prev.ryzst // {
    overrides.emacs = epkgs: epkgs // {
      #https://github.com/Alexander-Miller/treemacs/issues/1073
      treemacs = epkgs.melpaPackages.treemacs.overrideAttrs
        (old: {
          src = prev.fetchFromGitHub {
            owner = "Alexander-Miller";
            repo = "treemacs";
            rev = "529876dcc0d2c30667f1697c4eb7a5f137da4c3e";
            hash = "sha256-i03cUt/67XvDBNIatOTM7x1XujFS+/mXWhYUVlgd5+U=";
          };
        });
    };
  };
}
