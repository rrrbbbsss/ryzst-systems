self:
let
  # TODO: make nicer later.
  modulesList = self.lib.getFilesList ./modules;
  modules = self.lib.getFilesNoSuffix ./modules;
in
{
  default = { imports = modulesList; };
} // modules
