{ writeShellApplication
, coreutils-full
, findutils
, gnugrep
, unixtools
}:
writeShellApplication {
  name = "hardware-scanner";
  runtimeInputs = [
    coreutils-full
    findutils
    gnugrep
    unixtools.xxd
  ];
  text = builtins.readFile ./script.sh;
  meta.description = "Simple hardware scanner.";
}
