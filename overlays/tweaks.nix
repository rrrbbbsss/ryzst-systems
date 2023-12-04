final: prev:
{
  ryzst = prev.ryzst // {
    overrides.emacs = epkgs: epkgs // {
      #https://github.com/Alexander-Miller/treemacs/issues/1073
      doom-themes = epkgs.melpaPackages.doom-themes.overrideAttrs
        (old: {
          patches = [
            (prev.fetchpatch {
              url = "https://github.com/doomemacs/themes/pull/811.patch";
              sha256 = "sha256-dDzVtfWCaa+fC9yHMKrwD5kn+xo0oq4KdASa3GTKJIs=";
            })
          ];
        });
    };
  };
}
