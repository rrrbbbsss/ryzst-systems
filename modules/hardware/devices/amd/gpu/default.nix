{ lib, pkgs, ... }:
{
  boot.initrd.kernelModules = [ "amdgpu" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      amdvlk
      mesa.opencl
    ];
  };
  environment = {
    variables =
      {
        AMD_VULKAN_ICD = lib.mkDefault "RADV";
        RUSTICL_ENABLE = "radeonsi";
      };
    systemPackages = with pkgs; [
      glxinfo
    ];
  };
}
