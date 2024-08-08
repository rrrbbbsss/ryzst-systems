{ lib, runCommandLocal, makeWrapper, bash, iwd, fzf, gnused, gawk }:
runCommandLocal "fzf-wifi"
{
  script = ./script.sh;
  nativeBuildInputs = [ makeWrapper ];
} ''
  makeWrapper $script $out/bin/fzf-wifi \
  --prefix PATH : ${lib.makeBinPath [ bash iwd fzf gnused gawk ]}
''
