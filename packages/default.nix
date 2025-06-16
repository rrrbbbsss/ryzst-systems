self:
builtins.mapAttrs
  (name: value: value.ryzst)
  self.instances
