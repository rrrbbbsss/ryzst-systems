{ writeShellApplication
, fzf
, sway
, jq
}:

writeShellApplication {
  name = "fzf-sway-windows";
  runtimeInputs = [
    fzf
    jq
    sway
  ];
  text = builtins.readFile ./script.sh;
}
