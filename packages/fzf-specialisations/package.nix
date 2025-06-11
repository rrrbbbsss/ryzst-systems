{ writeShellApplication
, fzf
, nix
}:

writeShellApplication {
  name = "fzf-specialisations";
  runtimeInputs = [
    fzf
    nix
  ];
  text = builtins.readFile ./script.sh;
}
