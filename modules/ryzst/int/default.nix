{ self, lib, ... }:
{
  # TODO: don't import everything...
  imports = lib.foldlAttrs
    (acc: n: v: [ v.module ] ++ acc)
    [ ]
    self.domain.net.services;
}
