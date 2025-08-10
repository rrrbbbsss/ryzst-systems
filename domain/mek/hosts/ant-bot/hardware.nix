{ self, ... }:
{
  imports = [
    self.domain.hdw.devices.raspberry-pi."4b"
    self.domain.hdw.devices.brother.hl-l2300d
    self.domain.hdw.devices.canon.canoscan-lide-300
    self.domain.hdw.devices.creality.ender3-v3-se
    self.domain.hdw.devices.yubico.yubikey5
  ];
}
