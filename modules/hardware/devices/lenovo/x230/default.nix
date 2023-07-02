{ ... }:
{
  imports = [
    ../../../common/cpu/intel
    ../../../common/gpu/intel
    ../../../common/tpm/1-2
  ];

  device.keyboard = {
    remap.enable = true;
    name = "lenovo-x230";
    path = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
  };
}
