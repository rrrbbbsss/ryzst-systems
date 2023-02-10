{ config, pkgs, ... }:
{
  virtualisation.libvirtd = {
    enable = true;
    qemu.runAsRoot = false;
    onShutdown = "shutdown";
  };
}