{ config, lib, pkgs, ... }:
{
  boot.initrd.kernelModules = [ "amdgpu" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      amdvlk
      rocmPackages.clr
      rocmPackages.clr.icd
    ];
  };
  environment = {
    variables.AMD_VULKAN_ICD = lib.mkDefault "RADV";
    systemPackages = with pkgs; [
      glxinfo
      rocmPackages.rocminfo
    ];
  };
}
