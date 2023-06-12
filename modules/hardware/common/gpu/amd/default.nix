{ config, lib, pkgs, ... }:
{
  boot.initrd.kernelModules = [ "amdgpu" ];
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      amdvlk
      glxinfo
      rocm-opencl-icd
      rocm-opencl-runtime
      mesa.drivers
      rocminfo
    ];
  };
  environment.variables.AMD_VULKAN_ICD = lib.mkDefault "RADV";
}
