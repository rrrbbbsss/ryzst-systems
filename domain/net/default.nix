self:
let
  services = import ./services self;
in
{
  inherit services;
}
