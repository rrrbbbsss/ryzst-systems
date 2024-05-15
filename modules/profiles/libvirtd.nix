{ config, pkgs, ... }:
{
  # VMS
  users.users.${config.device.user}.extraGroups = [ "libvirtd" ];
  security.polkit.enable = true;
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
