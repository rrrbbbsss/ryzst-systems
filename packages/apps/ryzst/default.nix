{ lib, runCommandLocal, makeWrapper, bash, fzf }:
runCommandLocal "ryzst"
{
  script = ./script.sh;
  nativeBuildInputs = [ makeWrapper ];
} ''
  makeWrapper $script $out/bin/ryzst \
  --prefix PATH : ${lib.makeBinPath [ bash fzf ]}
''
