self:
final: prev:
let
  inherit (self.lib) mkBoxed;
  emacs-overlay = mkBoxed prev [
    self.inputs.emacs-overlay.overlays.default
    (import ./emacs-overlay)
  ];
  firefox-addons = mkBoxed prev [
    self.inputs.firefox-addons.overlays.default
    (import ./firefox-addons)
  ];
  nix-index-database = mkBoxed prev [
    self.inputs.nix-index-database.overlays.nix-index
    (import ./nix-index-database)
  ];
in
{
  inherit (emacs-overlay)
    emacsWithPackagesFromUsePackage;
  inherit (firefox-addons)
    firefox-addons;
  inherit (nix-index-database)
    nix-index-with-db;
}
