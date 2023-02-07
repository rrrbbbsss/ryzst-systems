{ pkgs, ... }:
{
  programs.mpv = {
    enable = true;
    config = {
      profile = "gpu-hq";
      scale = "spline36";
      cscale = "spline36";
      dscale = "mitchell";
      dither-depth = "auto";
      correct-downscaling = "yes";
      linear-downscaling = "yes";
      sigmoid-upscaling = "yes";
      deband = "yes";
      vo = "gpu";
      gpu-api = "vulkan";
      hwdec = "no";
    };
    bindings = {
      "Alt+H" = "add video-rotate 90";
      "Alt+L" = "add video-rotate -90";
      "Alt+J" = "add video-rotate 180";
      "Alt+K" = "add video-rotate -180";
      "Alt+-" = "add video-zoom -0.125";
      "Alt+=" = "add video-zoom 0.125";
      "Alt+h" = "add video-pan-x 0.01";
      "Alt+j" = "add video-pan-y -0.01";
      "Alt+k" = "add video-pan-y 0.01";
      "Alt+l" = "add video-pan-x -0.01";
      "Alt+BS" = "set video-zoom 0; set video-pan-x 0; set video-pan-y 0; set video-rotate no;";
    };
    defaultProfiles = [ "gpu-hq" ];
  };
}
