{ self }:

builtins.mapAttrs (name: import)
  (self.lib.getDirs ./.)
