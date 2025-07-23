{ config, ... }:
let
  username = config.device.user;
in
{
  home-manager.users.${username} = { pkgs, ... }: {
    systemd.user.tmpfiles.rules = [
      "e /home/${username}/.local/share/Trash - - - 3w"
      "e /home/${username}/.cache             - - - 3w"
    ];
  };
}
