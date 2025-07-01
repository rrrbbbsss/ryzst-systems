{ lib, ... }:

{
  imports = [
    ../../modules/hardware/common/display
    ../../modules/hardware/common/ethernet
    ../../modules/hardware/common/tpm
    ../../modules/hardware/common/wifi
    ../../modules/hardware/devices/amd/cpu
    ../../modules/hardware/devices/amd/gpu
    ../../modules/hardware/devices/kensington/expert-trackball-wireless
    ../../modules/hardware/devices/lenovo/trackpoint
    ../../modules/hardware/devices/yubico/yubikey5
  ];

  device.monitors = {
    DP-1 = {
      number = "0";
      mode = "3440x1440@144Hz";
    };
  };
  device.mirror = {
    main = "DP-1";
    secondary = "null";
  };

  #boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # BootLoader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.tmp = {
    useTmpfs = true;
    tmpfsSize = "80%";
  };
  boot.kernelParams = [
    "console=tty1"
  ];


  hardware.enableRedistributableFirmware = lib.mkDefault true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];

  # DISKS
  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/925b4d7c-09ac-4da9-9dc1-46a2b04b06b2";
      fsType = "ext4";
    };

  fileSystems."/boot/efi" =
    {
      device = "/dev/disk/by-uuid/035B-BE66";
      fsType = "vfat";
      options = [ "umask=0077" ];
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/7fb4c73f-04f2-434b-83cf-3eab9b829e31"; }];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

}
