self:
let
  inherit (self.inputs) nixpkgs;

  ryzst = final: prev:
    let
      # TODO: git rid fo "system..."
      system =
        if (final.hostPlatform.system == final.buildPlatform.system)
        then final.hostPlatform.system
        else "${final.buildPlatform.system}/${final.hostPlatform.system}";
    in
    { ryzst = self.lib.mkPackages ../packages final system; };

  tweaks = import ./tweaks.nix;

  # create a new fixed-point to throw "untrusted" overlays into.
  # that way they are unable fiddle with base instance (like poking at ssh).
  # for me for now,
  # this seems to work,
  # but a fixed-point expert should do something proper.
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
    nixpkgs.lib.composeManyExtensions
      [
        tweaks
        boxed
        ryzst
        # maybe a post tweaks?
      ];
}
