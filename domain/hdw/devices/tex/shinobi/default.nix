# TODO: remove self
{ self, ... }:
{
  imports = [
    self.domain.hdw.common.keyboards
    self.domain.hdw.common.rats
  ];

  device.rats = {
    "1241:1031:USB-HID_Keyboard_Mouse" = {
      natural_scroll = "disabled";
    };
  };

  device.keyboard = {
    remap.enable = true;
    name = "tex-shinobi";
    path = "/dev/input/by-id/usb-04d9_USB-HID_Keyboard_000000000407-event-kbd";
  };
}
