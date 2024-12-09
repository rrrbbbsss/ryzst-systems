{ pkgs, ... }:
{
  boot.initrd.kernelModules = [ "i915" ];
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      intel-vaapi-driver
      libvdpau-va-gl
      intel-media-driver
    ];
  };
  environment.variables = {
    VDPAU_DRIVER = "va_gl";
  };
}
