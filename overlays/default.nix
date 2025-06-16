self:
let
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
in
{
  inherit ryzst tweaks;
  default =
    self.inputs.nixpkgs.lib.composeManyExtensions
      [
        ryzst
        self.inputs.emacs-overlay.overlays.default
        self.inputs.firefox-addons.overlays.default
        self.inputs.nix-index-database.overlays.nix-index
        tweaks
      ];
}
