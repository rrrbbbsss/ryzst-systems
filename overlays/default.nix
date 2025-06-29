self:
let
  inherit (self.inputs) nixpkgs;

  # TODO: maybe move this?...
  ryzst = import ../packages self;

  tweaks = import ./tweaks;

  mkBoxed = prev: overlay:
    let
      f = final: prev;
      g = nixpkgs.lib.extends overlay f;
    in
    nixpkgs.lib.fix g;

  # TODO: maybe allow to tweak each input too?
  inputs = final: prev:
    let
      emacs-overlay = mkBoxed prev
        self.inputs.emacs-overlay.overlays.default;
      firefox-addons = mkBoxed prev
        self.inputs.firefox-addons.overlays.default;
      nix-index-database = mkBoxed prev
        self.inputs.nix-index-database.overlays.nix-index;
    in
    {
      inherit (emacs-overlay)
        emacsWithPackagesFromUsePackage;
      inherit (firefox-addons)
        firefox-addons;
      inherit (nix-index-database)
        nix-index-with-db;
    };
in
{
  inherit ryzst tweaks;
  default =
    nixpkgs.lib.composeManyExtensions [
      tweaks
      inputs
      ryzst
    ];
}
