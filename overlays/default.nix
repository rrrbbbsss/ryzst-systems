{ self }:
let
  ryzst = final: prev:
    let
      system =
        if (prev.hostPlatform.system == prev.buildPlatform.system)
        then prev.hostPlatform.system
        else "${prev.buildPlatform.system}/${prev.hostPlatform.system}";
    in
    {
      ryzst = self.packages.${system} // { inherit (self) lib; };
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
        self.inputs.firefox-addons.overlays.default
        tweaks
      ];
}
