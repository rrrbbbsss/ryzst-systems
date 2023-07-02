{ ... }:
{
  device.rats = {
    "6127:24814:Lenovo_TrackPoint_Keyboard_II_Mouse" = {
      natural_scroll = "disabled";
      accel_profile = "adaptive";
      pointer_accel = "0.75";
    };
  };

  device.keyboard = {
    remap.enable = true;
    name = "lenovo-trackpoint";
    path = "/dev/input/by-id/usb-Lenovo_TrackPoint_Keyboard_II-event-kbd";
  };
}
