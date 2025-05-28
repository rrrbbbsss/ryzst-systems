{ writeScriptBin }:
writeScriptBin "lambda-calculus"
  (builtins.readFile ./abstract-machine.pl)
