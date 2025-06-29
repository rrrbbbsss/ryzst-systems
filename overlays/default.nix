self:
let
  inherit (self.inputs) nixpkgs;

  # TODO: maybe move this?...
  ryzst = import ../packages self;

  tweaks = import ./tweaks;

  # https://www.youtube.com/watch?v=RBtchh_R4XY
  inputs = import ./inputs self;
in
{
  inherit tweaks inputs ryzst;
  default = nixpkgs.lib.composeManyExtensions [
    tweaks
    inputs
    ryzst
  ];
}
