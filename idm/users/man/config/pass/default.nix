{ config, ... }:
# TODO: make proper networkModules...
{
  home-manager.users.${config.device.user} = {
    programs.password-store = {
      enable = true;
    };
    home.sessionVariables = {
      PASSWORD_STORE_CLIP_TIME = "20";
    };
  };
}
