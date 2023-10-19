final: prev:
{
  #https://github.com/hyprwm/hyprpicker/issues/35
  hyprpicker = prev.hyprpicker.overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "hyprwm";
      repo = "hyprpicker";
      rev = "5ba32686943f839d072426d9ffd172decaee0e3e";
      hash = "sha256-3n0HJgo+3YCuo56a+efzcrh5UsfXi5jPU4tjqzJVm7g=";
    };
  });

  ryzst = prev.ryzst // {
    overrides.emacs = epkgs: epkgs // {
      #https://github.com/company-mode/company-mode/pull/1413
      company = epkgs.melpaPackages.company.overrideAttrs
        (old: {
          src = prev.fetchFromGitHub {
            owner = "company-mode";
            repo = "company-mode";
            rev = "a0c7c1775ab15d5d7df57a2126b6b9699049b7f0";
            hash = "sha256-ZnI8w9oXZCLxDI0qSXvTFAmuKJZ+dEvhzt5tiuzxpSY=";
          };
        });
    };
  };
}
