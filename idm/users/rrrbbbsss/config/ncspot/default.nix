{ config, ... }:
{
  home-manager.users.${config.device.user} = { pkgs, ... }:
    {
      programs.ncspot = {
        enable = true;
        settings = {
          use_nerdfont = true;
          backend = "pulseaudio";
          audio_cache = true;
          audio_cache_size = 5000;
          bitrate = 320;
          gapless = true;
          hide_display_names = true;
        };
      };
    };
}
