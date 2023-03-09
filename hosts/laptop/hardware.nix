{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    ../../modules/hardware/devices/lenovo/x230
    ../../modules/hardware/devices/yubico/yubikey5
  ];

  ryzst.hardware.monitors = {
    LVDS-1 = {
      mode = "1366x768@60Hz";
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
    tmpOnTmpfs = true;
    kernelParams = [ "console=tty1" ];
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  };

  fileSystems = {
    "/boot/efi" = {
      label = "BOOT";
      fsType = "vfat";
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
