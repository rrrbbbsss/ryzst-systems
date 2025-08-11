self:
let
  inherit (self.inputs) nixpkgs;
  tweaks = import ./tweaks self;
  inputs = import ./inputs self;
  packages = import ./packages self;
in
{
  inherit tweaks inputs packages;
  default = nixpkgs.lib.composeManyExtensions [
    tweaks
    inputs
    packages
  ];
}
