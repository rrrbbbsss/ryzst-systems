{ writeShellApplication
, pass-wayland
, fzf
}:

writeShellApplication {
  name = "fzf-pass";
  runtimeInputs = [
    pass-wayland
    fzf
  ];
  text = builtins.readFile ./script.sh;
}
