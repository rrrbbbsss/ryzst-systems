{ config, pkgs, ... }:
{
  # VMS
  users.users.${config.device.user}.extraGroups = [ "libvirtd" ];
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      runAsRoot = false;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [ pkgs.OVMFFull.fd ];
      };
    };
    onShutdown = "shutdown";
  };
}
