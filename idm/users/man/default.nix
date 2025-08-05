{ config, self, ... }:
let
  username = config.device.user;
in
{
  imports = self.lib.getDirsList ./config;

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
