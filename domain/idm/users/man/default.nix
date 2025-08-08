{ config, self, ... }:
let
  username = config.device.user;
in
{
  imports = self.lib.getDirsList ./config;

  device.user = baseNameOf (toString ./.);

  users.users.${username} = {
    isNormalUser = true;
    inherit (self.domain.idm.users.${username}) uid;
    description = "${self.domain.idm.users.${username}.first} ${self.domain.idm.users.${username}.last}";
    hashedPassword = null;
  };
}
