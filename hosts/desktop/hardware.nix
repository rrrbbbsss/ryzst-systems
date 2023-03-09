{ config, lib, pkgs, modulesPath, ... }:

{

  imports = [
    ../../modules/hardware/devices/tex/shinobi
  ];
  
  ryzst.hardware.monitors = {
    DP-1 = {
      mode = "2560x1440@75Hz";
      position = "1200 2160";
    };
    DP-2 = {
      mode = "1920x1200@75Hz";
      position = "0 2160";
      transform = "270";
    };
    DP-3 = {
      mode = "3840x2160@30Hz";
      position = "560 0";
    };
    DP-4 = {
      mode = "1920x1200@75Hz";
      transform = "90";
      position = "3760 2160";
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