# TODO: remove self
{ self, ... }:
{
  imports = [
    self.domain.hdw.common.keyboards
    self.domain.hdw.common.rats
  ];

  device.rats = {
    "9354:33639:Telink_Wireless_Receiver_Mouse" = {
      natural_scroll = "enabled";
    };
  };
}
