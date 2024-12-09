{ pkgs, ... }:
let
  replacements = [ ];
in
{
  system.replaceDependencies.replacements = replacements;
  # grafting is impure :(
  system.autoUpgrade.flags =
    if replacements == [ ]
    then [ ]
    else [ "--impure" ];
}
