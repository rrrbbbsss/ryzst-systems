# TODO: remove self
{ self, ... }:
# never connecting this to network.
{
  imports = [
    self.hardwareModules.common.ir
  ];

  device.ir.code.receiver = {
    power = ./power.ir;
    volume-down = ./volume-down.ir;
    volume-up = ./volume-up.ir;
  };
}
