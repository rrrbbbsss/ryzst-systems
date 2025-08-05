{ self, ... }:
{
  imports = self.lib.getDirsList ./.;
}
