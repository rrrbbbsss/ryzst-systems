{ config, lib, self, ... }:
with lib;
let
  # TODO: move this out...
  groups = {
    admins = {
      inherit (config.ryzst.idm.users)
        man;
    };
  };
in
{
  # TODO: do better...
  imports = [
    self.domain.idm.groups.admins.module
  ];

  options.ryzst.idm = {
    users = mkOption {
      description = "Users information";
      type = types.attrs;
      default = self.domain.idm.users;
    };
    groups = mkOption {
      description = "Groups are sets of users";
      type = types.attrs;
      default = groups;
    };
  };
}
