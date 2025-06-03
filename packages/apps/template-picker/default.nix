{ writeShellApplication
, fzf
, nix
, git
, findutils
}:
writeShellApplication {
  name = "template-picker";
  runtimeInputs = [
    fzf
    nix
    git
    findutils
  ];
  text = builtins.readFile ./script.sh;
}
