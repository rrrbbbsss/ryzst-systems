{ self, ... }:
{
  imports = [
    self.domain.idm.users.man.module
  ];
}
