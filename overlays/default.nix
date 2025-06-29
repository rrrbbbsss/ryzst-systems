self:
let
  inherit (self.inputs) nixpkgs;

  # TODO: maybe move this?...
  ryzst = import ../packages self;

  tweaks = import ./tweaks self;

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
