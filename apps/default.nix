self:
let
  inherit (self) instances;
in
self.lib.mkSystems self (system:
with instances.${system.string}.ryzst;
{
  default = {
    type = "app";
    program = "${apps}/bin/ryzst";
  };
  burn-iso = {
    type = "app";
    program = "${apps}/bin/burn-iso";
  };
  ryzst-installer = {
    type = "app";
    program = "${apps}/bin/ryzst-installer";
  };
  yubikey-setup = {
    type = "app";
    program = "${apps}/bin/yubikey-setup";
  };
})

