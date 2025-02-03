{ ... }:
{
  imports = [
    ../../../common/cpu/intel
    ../../../common/gpu/intel
    ../../../common/tpm/2-0
    ../../../common/wifi
  ];

  services.throttled.enable = true;

  device.monitors = {
    eDP-1 = {
      number = "0";
      mode = "1920x1080@60Hz";
    };
    HDMI-2 = {
      number = "1";
    };
  };

  device.rats = {
    "1267:32:Elan_TrackPoint" = {
      natural_scroll = "disabled";
      accel_profile = "adaptive";
      pointer_accel = "1";
    };
    "1267:32:Elan_Touchpad" = {
      events = "disabled";
    };
  };

  device.keyboard = {
    remap.enable = true;
    name = "lenovo-t480s";
    path = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
  };
}
