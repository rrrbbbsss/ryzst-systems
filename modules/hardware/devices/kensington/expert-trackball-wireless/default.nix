# TODO: remove self
{ self, ... }:
{
  imports = [
    self.hardwareModules.common.rats
  ];

  device.rats = {
    "1149:32792:Kensington_Expert_Wireless_TB_Mouse" = {
      scroll_button = "BTN_SIDE";
      scroll_button_lock = "enabled";
      scroll_method = "on_button_down";
      natural_scroll = "enabled";
    };
  };
}
