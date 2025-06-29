self:
let
  inherit (self.inputs) nixpkgs;

  # TODO: maybe move this?...
  ryzst = import ../packages self;

  tweaks = import ./tweaks.nix;

  # should create a new fixedpoint for each "3rd-party" overlay...
  # that way they can't change eachother...
  boxed = final: prev:
    let
      inherit (self.inputs) nixpkgs;
      instance = final: prev;
      g = nixpkgs.lib.extends
        (nixpkgs.lib.composeManyExtensions [
          self.inputs.emacs-overlay.overlays.default
          self.inputs.firefox-addons.overlays.default
          self.inputs.nix-index-database.overlays.nix-index
        ])
        instance;
      boxed-instance = nixpkgs.lib.fix g;
    in
    {
      inherit (boxed-instance)
        #firefox-addons
        firefox-addons
        #emacs-overlay
        emacsWithPackagesFromUsePackage
        #nix-index-database
        nix-index-with-db;
    };
in
{
  inherit ryzst tweaks;
  default =
    nixpkgs.lib.composeManyExtensions [
      tweaks
      boxed
      ryzst
    ];
}
