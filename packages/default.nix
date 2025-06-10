self:
let
  inherit (self) instances lib;
in
self.lib.mkSystems (system:
let
  pkgs = instances.${system.string};
  mkPackages = dir:
    pkgs.lib.foldlAttrs
      (acc: name: path:
        acc // (import path {
          inherit self lib pkgs;
          system = system.string;
        })
      )
      { }
      (self.lib.getDirs dir);
in
mkPackages ./.)
