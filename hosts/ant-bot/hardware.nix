{ self, ... }:
{
  imports = [
    self.hardwareModules.devices.raspberry-pi."4b"
    self.hardwareModules.devices.brother.hl-l2300d
    self.hardwareModules.devices.canon.canoscan-lide-300
    self.hardwareModules.devices.creality.ender3-v3-se
    self.hardwareModules.devices.yubico.yubikey5
  ];
}
