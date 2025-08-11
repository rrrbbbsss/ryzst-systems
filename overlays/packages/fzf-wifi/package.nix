{ writeShellApplication
, iwd
, fzf
, gnused
, gawk
}:

writeShellApplication {
  name = "fzf-wifi";
  runtimeInputs = [
    fzf
    gawk
    gnused
    iwd
  ];
  text = builtins.readFile ./script.sh;
}
