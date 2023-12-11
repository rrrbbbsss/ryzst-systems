final: prev:
{
  ryzst = prev.ryzst // {
    overrides.emacs = epkgs: epkgs // { };
  };
}
