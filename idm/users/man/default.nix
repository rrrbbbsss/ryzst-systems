{ config, self, ... }:
let
  username = config.device.user;
in
{
  imports = [
    ./config/sway
    ./config/wireshark
    ./config/zsh
    ./config/ncspot
    ./config/alacritty
    ./config/emacs
    ./config/firefox
    ./config/gpg
    ./config/mpv
    ./config/waybar
    ./config/zathura
    ./config/pass
    ./config/git
    ./config/packages
    ./config/trash
  ];

  device.user = baseNameOf (toString ./.);

  users.users.${username} = {
    isNormalUser = true;
    uid = self.outputs.lib.names.user.toUID username;
    # TODO: full name
    description = username;
    hashedPassword = null;
    # TODO: don't do this here
    extraGroups = [ "wheel" ];
  };
}
