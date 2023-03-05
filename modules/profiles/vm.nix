{ config, pkgs, home-manager, ... }:
{
  # sway
  environment.variables = {
    WLR_NO_HARDWARE_CURSORS = "1";
  };
  hardware.opengl = {
    enable = true;
  };

  # yubikey
  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  virtualisation = {
    cores = 4;
    memorySize = 4096;
    qemu = {
      guestAgent.enable = true;
      options = [ 
        # sway
        "-device qxl-vga,vgamem_mb=32" 
        # yubikey
        "-usb -device usb-host,vendorid=0x1050,productid=0x0406" ];
    };
  };
}
