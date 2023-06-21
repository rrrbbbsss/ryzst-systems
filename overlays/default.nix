{ self }:
let
  ryzst = final: prev: {
    ryzst = self.packages.${prev.system};
    firefox-addons = self.inputs.firefox-addons.packages.${prev.system};
    lib = prev.lib // { ryzst = self.lib; };
  };
  good-old-packages = import ./good-old-packages.nix;
  new-fixes = import ./new-fixes.nix;
in
{
  inherit ryzst good-old-packages;
  default =
    self.inputs.nixpkgs.lib.composeManyExtensions
      [
        ryzst
        self.inputs.nix-vscode-extensions.overlays.default
        self.inputs.emacs-overlay.overlays.default
        good-old-packages
        new-fixes
      ];
}
