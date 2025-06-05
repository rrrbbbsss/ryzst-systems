{ lib, ... }:
# my ryzen 7 5700G was having issues with random reboots/freezing.
# had to disable "AMD Cool n' Quiet" in BIOS.
{
  hardware.enableRedistributableFirmware = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = true;
  boot.kernelModules = [ "kvm-amd" ];
}
