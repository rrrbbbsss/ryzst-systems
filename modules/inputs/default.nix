self:
let
  # TODO: make nicer later.
  # this is too jank but just want to seperate them out.
  # must pass external modules in better...
  modulesList = self.lib.getFilesList ./modules;
  modules = self.lib.getFilesNoSuffix ./modules;
in
{
  default = { imports = modulesList; };
} // modules
