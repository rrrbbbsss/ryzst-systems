self:
let
  # TODO: make nicer later.
  # (also make directory for each module and eventually add tests...)
  modulesList = self.lib.getFilesList ./modules;
  modules = self.lib.getFilesNoSuffix ./modules;
in
{
  default = { imports = modulesList; };
} // modules
