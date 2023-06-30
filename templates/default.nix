{ self }:

builtins.mapAttrs (name: value: import value)
  (self.lib.getDirs ./.)
