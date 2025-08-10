{ self, pkgs, ... }:

{
  imports = [
    self.domain.hdw.common.display
    self.domain.hdw.common.ethernet
    self.domain.hdw.common.tpm
    self.domain.hdw.common.wifi
    self.domain.hdw.devices.intel.cpu
    self.domain.hdw.devices.intel.gpu
    self.domain.hdw.devices.vontar.d8
    self.domain.hdw.devices.funai.lf320fx4f
    self.domain.hdw.devices.denon.dra-800h
    self.domain.hdw.devices.yubico.yubikey5
  ];

  device.monitors = {
    HDMI-1 = {
      number = "1";
      mode = "1920x1080@60Hz";
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        efiSysMountPoint = "/boot/efi";
        canTouchEfiVariables = true;
      };
    };
    tmp = {
      useTmpfs = true;
      tmpfsSize = "80%";
    };
    kernelParams = [ "console=tty1" ];
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  };

  fileSystems = {
    "/boot/efi" = {
      label = "BOOT";
      fsType = "vfat";
      options = [ "umask=0077" ];
    };
    "/" = {
      label = "ROOT";
      fsType = "ext4";
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };
}
