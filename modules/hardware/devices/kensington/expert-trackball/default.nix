{ ... }:
{
  imports = [
    ../../../common/rats
  ];

  device.rats = {
    "1149:4128:Kensington_Expert_Mouse" = {
      scroll_button = "BTN_SIDE";
      scroll_button_lock = "enabled";
      scroll_method = "on_button_down";
      natural_scroll = "enabled";
    };
  };
}
