{ config, ... }:
{
  services.kanata = {
    enable = true;
    keyboards = {
      "lenovo-trackpoint" = {
        devices = [ "/dev/input/by-id/usb-Lenovo_TrackPoint_Keyboard_II-event-kbd" ];
        port = null;
        config = builtins.readFile ../../../common/keyboards/kanata.scm;
      };
    };
  };
}
