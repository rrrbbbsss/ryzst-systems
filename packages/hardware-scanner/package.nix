{ writeShellApplication
, coreutils-full
, findutils
, gnugrep
}:
writeShellApplication {
  name = "hardware-scanner";
  runtimeInputs = [
    coreutils-full
    findutils
    gnugrep
  ];
  text = builtins.readFile ./script.sh;
  meta.description = "Simple hardware scanner.";
}
