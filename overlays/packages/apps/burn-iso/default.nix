{ writeShellApplication
, fzf
, coreutils-full
, util-linux
, gawk
}:
writeShellApplication {
  name = "burn-iso";
  runtimeInputs = [
    fzf
    coreutils-full
    util-linux
    gawk
  ];
  text = builtins.readFile ./script.sh;
}
