{ ... }:

{
  imports = [
    ../../modules/hardware/devices/lenovo/t480s
    ../../modules/hardware/devices/yubico/yubikey5
  ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

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
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  disko.devices = {
    disk = {
      sda = {
        device = "/dev/nvme0n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            BOOT = {
              label = "BOOT";
              type = "EF00";
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountOptions = [ "umask=0077" ];
                mountpoint = "/boot/efi";
              };
            };
            ROOT = {
              label = "ROOT";
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
