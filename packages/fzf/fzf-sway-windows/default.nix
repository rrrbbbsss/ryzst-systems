{ lib, runCommandLocal, makeWrapper, bash, fzf, sway, jq }:
runCommandLocal "fzf-sway-windows"
{
  script = ./script.sh;

  nativeBuildInputs = [ makeWrapper ];
} ''
  makeWrapper $script $out/bin/fzf-sway-windows \
  --prefix PATH : ${lib.makeBinPath [ bash fzf sway jq ]}
''
