{ writeShellApplication
, fzf
}:
writeShellApplication {
  name = "ryzst";
  runtimeInputs = [
    fzf
  ];
  text = builtins.readFile ./script.sh;
}
