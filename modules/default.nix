self:
# TODO: clean this up...
{
  default = {
    imports = [
      ./ryzst
      self.nixosModules.default
      # TODO: think about better place for this
      (import ./inputs self).default
      (import ./settings self).default
    ];
  };
}
