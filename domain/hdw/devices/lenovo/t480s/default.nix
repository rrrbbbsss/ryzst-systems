# TODO: remove self
{ self, ... }:
{
  imports = [
    self.domain.hdw.common.display
    self.domain.hdw.common.tpm
    self.domain.hdw.common.wifi
    self.domain.hdw.common.keyboards
    self.domain.hdw.common.rats
    self.domain.hdw.common.ethernet
    self.domain.hdw.devices.intel.cpu
    self.domain.hdw.devices.intel.gpu
  ];

  services.throttled.enable = true;
  hardware.bluetooth.enable = true;

  device.monitors = {
    eDP-1 = {
      number = "0";
      mode = "1920x1080@60Hz";
    };
    HDMI-A-2 = {
      number = "1";
    };
  };

  device.mirror = {
    main = "eDP-1";
    secondary = "HDMI-A-2";
  };

  device.rats = {
    "1267:32:Elan_TrackPoint" = {
      natural_scroll = "disabled";
      accel_profile = "adaptive";
      pointer_accel = "1";
    };
    "1267:32:Elan_Touchpad" = {
      events = "disabled";
    };
  };

  device.keyboard = {
    remap.enable = true;
    name = "lenovo-t480s";
    path = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
  };

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
