{ config, pkgs, ... }:

{
  ######################
  ### Virtualization ###
  ######################


  # for cursor to show up with sway in vm
  environment.variables = {
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  hardware.opengl = {
    enable = true;
  };

  virtualisation = {
    cores = 4;
    memorySize = 4096;
    qemu = {
      guestAgent.enable = true;
      options = [ "-device qxl-vga,vgamem_mb=32" ];
    };
  };
}