{ self }:
let
  ryzst = final: prev: {
    ryzst = self.packages.${prev.system} // { inherit (self) lib; };
    firefox-addons = self.inputs.firefox-addons.packages.${prev.system};
  };
  tweaks = import ./tweaks.nix;
in
{
  inherit ryzst tweaks;
  default =
    self.inputs.nixpkgs.lib.composeManyExtensions
      [
        ryzst
        self.inputs.emacs-overlay.overlays.default
        tweaks
      ];
}
