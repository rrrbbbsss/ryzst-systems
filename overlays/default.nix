{ self }:
let
  ryzst = final: prev: {
    ryzst = self.packages.${prev.system};
    firefox-addons = self.inputs.firefox-addons.packages.${prev.system};
    lib = prev.lib // { ryzst = self.lib; };
  };
  tweaks = import ./tweaks.nix;
in
{
  inherit ryzst tweaks;
  default =
    self.inputs.nixpkgs.lib.composeManyExtensions
      [
        ryzst
        self.inputs.nix-vscode-extensions.overlays.default
        self.inputs.emacs-overlay.overlays.default
        tweaks
      ];
}
