{ config, ... }:
{
  services.kanata = {
    enable = true;
    keyboards = {
      "tex-shinobi" = {
        devices = [ "/dev/input/by-id/usb-04d9_USB-HID_Keyboard_000000000407-event-kbd" ];
        port = null;
        config = builtins.readFile ../../../common/keyboards/kanata.scm;
      };
    };
  };
}
