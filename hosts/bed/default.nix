{ config, ... }:
{
  imports = [
    ../../modules/profiles/base.nix
    ../../modules/profiles/nfs.nix
    ../../idm/users/rrrbbbsss
  ];

  # VMS
  users.users.${config.device.user}.extraGroups = [ "libvirtd" ];
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      runAsRoot = false;
      swtpm.enable = true;
    };
    onShutdown = "shutdown";
  };

  # Printer
  services.printing = {
    enable = true;
  };
}
