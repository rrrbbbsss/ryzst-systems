{ config, self, ... }:
let
  username = config.device.user;
in
{
  imports = self.lib.getDirsList ./config;

  device.user = baseNameOf (toString ./.);

  users.users.${username} = {
    isNormalUser = true;
    inherit (self.idm.users.${username}) uid;
    description = "${self.idm.users.${username}.first} ${self.idm.users.${username}.last}";
    hashedPassword = null;
  };
}
