{ config, lib, ... }:
let
  username = if config.device.user == null then "" else config.device.user;
  isMember = config.ryzst.idm.groups.admins?${username};
in
lib.mkIf isMember {
  users.users.${username} = {
    extraGroups = [ "wheel" ];
  };
}
