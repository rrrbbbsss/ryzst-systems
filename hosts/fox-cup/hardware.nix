{ self, ... }:
{
  imports = [
    self.hardwareModules.devices.lenovo.t480s
    self.hardwareModules.devices.yubico.yubikey5
  ];
}
