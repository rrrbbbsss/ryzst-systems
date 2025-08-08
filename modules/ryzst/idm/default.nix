{ config, lib, self, ... }:
with lib;
let
  mkUsers = dir: with builtins;
    mapAttrs
      (n: v: {
        uid = self.outputs.lib.names.user.toUID n;
        keys = {
          gpg = dir + "/${n}/pubkeys/gpg.pub";
          ssh = dir + "/${n}/pubkeys/ssh.pub";
          x509 = dir + "/${n}/pubkeys/x509.crt";
        };
        module = dir + "/${n}/default.nix";
      })
      (self.lib.getDirs dir);

  groups = {
    admins = {
      inherit (config.ryzst.idm.users)
        man;
    };
  };
in
{

  # TODO: nasty nasty...
  imports = [
    ../../../domain/idm/groups/admins
  ];

  options.ryzst.idm = {
    users = mkOption {
      description = "Users information";
      type = types.attrs;
      default = mkUsers ../../../domain/idm/users;
    };
    groups = mkOption {
      description = "Groups are sets of users";
      type = types.attrs;
      default = groups;
    };
  };
}
