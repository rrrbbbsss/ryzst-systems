{ ... }:
{
  imports = [
    ../../../common/cpu/intel
    ../../../common/gpu/intel
    ../../../common/tpm/1-2
  ];

  device.monitors = {
    LVDS-1 = {
      number = "0";
      mode = "1366x768@60Hz";
    };
    VGA-1 = {
      number = "1";
    };
    DP-1 = {
      number = "2";
    };
  };

  device.keyboard = {
    remap.enable = true;
    name = "lenovo-x230";
    path = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
  };
}
