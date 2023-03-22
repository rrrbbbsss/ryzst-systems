{ pkgs, ... }:
{
  programs.mpv = {
    enable = true;
    config = {
      profile = "gpu-hq";
      scale = "ewa_lanczossharp";
      cscale = "ewa_lanczossharp";
      video-sync = "display-resample";
      interpolation = true;
      tscale = "oversample";
      gpu-hwdec-interop = "vaapi";
      hwdec = "auto";
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
