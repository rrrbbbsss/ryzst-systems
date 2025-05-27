# https://www.youtube.com/watch?v=JBc0h3IVjkc
{ writeScriptBin }:
writeScriptBin "lambda-calculus"
  (builtins.readFile ./abstract-machine.pl)
