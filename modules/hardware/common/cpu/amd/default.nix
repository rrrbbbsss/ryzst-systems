{ config, lib, ... }:
# https://www.youtube.com/watch?v=thmR2SmkeDU
# my ryzen 7 5700G was having issues with random reboots/freezing.
# had to disable "AMD Cool n' Quiet" in BIOS.
# will have to see if it holds or not,
# otherwise will have to poke through arch wiki:
# https://wiki.archlinux.org/title/Ryzen#Troubleshooting
{
  hardware.enableRedistributableFirmware = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = true;
  boot.kernelModules = [ "kvm-amd" ];
}
