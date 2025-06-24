{ ... }:
# never connecting this to network.
{
  imports = [
    ../../../common/ir
  ];

  device.ir.code.tv = {
    power = ./power.ir;
  };
}
