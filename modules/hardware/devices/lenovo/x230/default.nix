{ config, ... }:
{
  imports = [
    ../../../common/cpu/intel
    ../../../common/gpu/intel
  ];
  services.kanata = {
    enable = true;
    keyboards = {
      "lenovo-x230" = {
        devices = [ "/dev/input/by-path/platform-i8042-serio-0-event-kbd" ];
        port = null;
        config = builtins.readFile ../common/keyboards/kanata.scm;
      };
    };
  };
}
