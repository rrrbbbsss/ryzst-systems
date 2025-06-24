{ ... }:
{
  imports = [
    ../../../common/display
    ../../../common/wifi
    ../../../common/keyboards
    ../../../common/rats
    ../../../devices/intel/cpu
    ../../../devices/intel/gpu
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

  device.mirror = {
    main = "LVDS-1";
    secondary = "VGA-1";
  };

  device.rats = {
    "2:10:TPPS/2_IBM_TrackPoint" = {
      natural_scroll = "disabled";
      accel_profile = "adaptive";
      pointer_accel = "1";
    };
  };

  device.keyboard = {
    remap.enable = true;
    name = "lenovo-x230";
    path = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
  };
}
