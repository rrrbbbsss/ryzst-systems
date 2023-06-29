{ lib, runCommandLocal, makeWrapper, bash, fzf }:
runCommandLocal "template-picker"
{
  script = ./script.sh;
  nativeBuildInputs = [ makeWrapper ];
} ''
  makeWrapper $script $out/bin/template-picker \
  --prefix PATH : ${lib.makeBinPath [ bash fzf ]}
''
