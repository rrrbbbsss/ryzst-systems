self:
let
  users = import ./users self;
  groups = import ./groups self;
  kiosks = import ./kiosks self;
in
{
  inherit users groups kiosks;
}
