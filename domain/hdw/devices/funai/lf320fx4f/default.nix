# TODO: remove self
{ self, ... }:
# never connecting this to network.
{
  imports = [
    self.domain.hdw.common.ir
  ];

  device.ir.code.tv = {
    power = ./power.ir;
  };
}
