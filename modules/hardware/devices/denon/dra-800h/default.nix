{ ... }:
# never connecting this to network.
{
  imports = [
    ../../../common/ir
  ];

  device.ir.code.receiver = {
    power = ./power.ir;
    volume-down = ./volume-down.ir;
    volume-up = ./volume-up.ir;
  };
}
