# TODO: remove self
{ self, ... }:
{
  imports = [
    self.hardwareModules.common.keyboards
    self.hardwareModules.common.rats
  ];

  device.rats = {
    "9354:33639:Telink_Wireless_Receiver_Mouse" = {
      natural_scroll = "enabled";
    };
  };
}
