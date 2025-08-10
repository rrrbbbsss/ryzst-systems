{ self, ... }:
{
  imports = [
    self.domain.hdw.devices.lenovo.t480s
    self.domain.hdw.devices.yubico.yubikey5
  ];
}
