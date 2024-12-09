{ ... }:
{
  imports = [
    ../../modules/hardware/devices/yubico/yubikey5
  ];

  nixpkgs.hostPlatform.system = "x86_64-linux";

  # sway
  environment.variables = {
    WLR_NO_HARDWARE_CURSORS = "1";
  };
  hardware.graphics = {
    enable = true;
  };

  device.monitors = {
    Virtual-1 = {
      number = "0";
      mode = "1024x768@60Hz";
    };
  };

  virtualisation = {
    cores = 4;
    memorySize = 4096;
    qemu = {
      guestAgent.enable = true;
      options = [
        # sway
        "-device qxl-vga,vgamem_mb=32"
        # yubikey
        "-usb -device usb-host,vendorid=0x1050,productid=0x0406"
      ];
    };
  };
}
