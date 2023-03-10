{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    ../../modules/hardware/common/cpu/amd
    ../../modules/hardware/common/gpu/amd
    ../../modules/hardware/devices/lenovo/trackpoint
    ../../modules/hardware/devices/yubico/yubikey5
  ];

  ryzst.hardware.monitors = {
    DP-1 = {
      mode = "3440x1440@144Hz";
    };
  };

  # BootLoader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.tmpOnTmpfs = true;
  boot.kernelParams = [ "console=tty1" ];


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
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/7fb4c73f-04f2-434b-83cf-3eab9b829e31"; }];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  # NICS
  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp4s0.useDHCP = lib.mkDefault true;
}
