{ self, ... }:

{

  imports = [
    self.domain.hdw.common.display
    self.domain.hdw.common.ethernet
    self.domain.hdw.devices.intel.cpu
    self.domain.hdw.devices.amd.gpu
    self.domain.hdw.devices.kensington.expert-trackball
    self.domain.hdw.devices.tex.shinobi
    self.domain.hdw.devices.nullbits.tidbit
    self.domain.hdw.devices.microchip.ir-transceiver
    self.domain.hdw.devices.sceptre.u550cv-u
    self.domain.hdw.devices.yubico.yubikey5
  ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  device.monitors = {
    DP-1 = {
      number = "0";
      mode = "2560x1440@75Hz";
      position = "1200 2160";
    };
    DP-2 = {
      number = "1";
      mode = "1920x1200@75Hz";
      position = "0 2160";
      transform = "270";
    };
    DP-3 = {
      number = "2";
      mode = "3840x2160@30Hz";
      position = "560 0";
    };
    DP-4 = {
      number = "3";
      mode = "1920x1200@75Hz";
      transform = "90";
      position = "3760 2160";
    };
  };
  device.mirror = {
    main = "DP-1";
    secondary = "DP-3";
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
    kernelParams = [ "mem_sleep_default=shallow" "amdgpu.aspm=0" ];
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
