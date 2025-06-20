{ writeShellApplication
, coreutils-full
, findutils
, gawk
}:
# TODO: rename this...
writeShellApplication {
  name = "root-cleaner";
  runtimeInputs = [
    coreutils-full
    findutils
    gawk
  ];
  text = builtins.readFile ./script.sh;
  meta.description = "Cleans up old result/direnv roots";
}
