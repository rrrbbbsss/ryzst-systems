{ pkgs, ... }:
{
  boot.initrd.kernelModules = [ "i915" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-vaapi-driver
      libvdpau-va-gl
      intel-media-driver
      mesa.opencl
    ];
  };
  environment.variables = {
    VDPAU_DRIVER = "va_gl";
    RUSTICL_ENABLE = "iris";
  };
}
