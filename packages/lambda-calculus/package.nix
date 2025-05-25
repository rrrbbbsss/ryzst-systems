# https://www.youtube.com/watch?v=--1SS0bfUWg
# yea, never really been able to have
# a conversation with someone
# about lambda-calculus...
# life be like that.
{ writeScriptBin }:
writeScriptBin "lambda-calculus"
  (builtins.readFile ./abstract-machine.pl)
