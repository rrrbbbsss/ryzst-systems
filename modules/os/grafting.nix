{ pkgs, ... }:
let
  replacements = [ ];
in
{
  system.replaceRuntimeDependencies = replacements;
  # grafting is impure :(
  system.autoUpgrade.flags =
    if replacements == [ ]
    then [ ]
    else [ "--impure" ];
}
