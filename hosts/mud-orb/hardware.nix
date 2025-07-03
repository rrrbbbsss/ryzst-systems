{ self, pkgs, ... }:

{
  imports = [
    self.hardwareModules.common.display
    self.hardwareModules.common.ethernet
    self.hardwareModules.common.tpm
    self.hardwareModules.common.wifi
    self.hardwareModules.devices.intel.cpu
    self.hardwareModules.devices.intel.gpu
    self.hardwareModules.devices.vontar.d8
    self.hardwareModules.devices.funai.lf320fx4f
    self.hardwareModules.devices.denon.dra-800h
    self.hardwareModules.devices.yubico.yubikey5
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
