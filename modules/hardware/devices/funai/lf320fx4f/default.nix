# TODO: remove self
{ self, ... }:
# never connecting this to network.
{
  imports = [
    self.hardwareModules.common.ir
  ];

  device.ir.code.tv = {
    power = ./power.ir;
  };
}
