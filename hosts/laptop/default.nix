{ config, ... }:
{
  imports = [
    # ../../idm/users/rrrbbbsss
  ];

  #for testing
  device.user = "rrrbbbsss";
  users.users.${config.device.user} = {
    isNormalUser = true;
    description = config.device.user;
    extraGroups = [ "wheel" ];
    hashedPassword = null;
  };
}
