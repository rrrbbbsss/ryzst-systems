{ self, ... }:
let
  programs = self.lib.getFilesList ./programs;
in
{
  imports = programs;
}
