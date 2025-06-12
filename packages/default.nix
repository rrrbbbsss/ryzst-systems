self:
let
  inherit (self) instances lib;
in
lib.mkSystems (system:
lib.mkPackages ./.
  instances.${system.string}
  system)
