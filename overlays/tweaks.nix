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
}
