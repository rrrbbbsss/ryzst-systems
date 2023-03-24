{ config, pkgs, ... }:
{
  imports = [
    ../../modules/profiles/base.nix
    ../../modules/profiles/core.nix
    ../../modules/profiles/sway.nix
    ../../modules/profiles/nfs.nix
    ../../idm/users/rrrbbbsss
  ];

  # VMS
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
