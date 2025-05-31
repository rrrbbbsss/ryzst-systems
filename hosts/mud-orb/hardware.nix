{ pkgs, ... }:

{
  imports = [
    ../../modules/hardware/common/cpu/intel
    ../../modules/hardware/common/gpu/intel
    ../../modules/hardware/common/tpm/2-0
    ../../modules/hardware/common/wifi
    ../../modules/hardware/devices/yubico/yubikey5
    ../../modules/hardware/devices/vontar/d8
  ];

  device.monitors = {
    HDMI-1 = {
      number = "1";
      mode = "1920x1080@60Hz";
    };
  };

  boot = {
    # TODO: remove when iwlwifi driver not pooped.
    kernelPackages = pkgs.linuxKernel.packages.linux_6_11;
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
