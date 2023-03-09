{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    ../../modules/hardware/devices/lenovo/x230
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

  # CPU
  hardware.enableRedistributableFirmware = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
  boot.kernelModules = [ "kvm-intel" ];

  # yubikey
  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

}
