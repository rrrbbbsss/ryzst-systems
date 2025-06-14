{ writeShellApplication
, coreutils-full
, fzf
, git
, findutils
}:
writeShellApplication {
  name = "template-picker";
  runtimeInputs = [
    coreutils-full
    fzf
    git
    findutils
  ];
  # TODO: redo all the templates...
  text = ''
    templates=${./templates}
  '' + builtins.readFile ./script.sh;
}
