{ config, ... }:
{
  imports = [
    ../../idm/users/rrrbbbsss
  ];

  # VMS
  users.users.${config.device.user}.extraGroups = [ "libvirtd" ];
  virtualisation.libvirtd = {
    enable = true;
    qemu.runAsRoot = false;
    onShutdown = "shutdown";
  };

  # Printer
  services.printing = {
    enable = true;
  };
}
