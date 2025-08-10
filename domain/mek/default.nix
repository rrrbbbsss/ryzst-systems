self:
let
  hosts = import ./hosts self;
in
{
  inherit hosts;
}
