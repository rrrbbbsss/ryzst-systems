{ lib, runCommandLocal, makeWrapper, bash, pass-wayland, fzf }:
runCommandLocal "fzf-pass"
{
  script = ./script.sh;
  nativeBuildInputs = [ makeWrapper ];
} ''
  makeWrapper $script $out/bin/fzf-pass \
  --prefix PATH : ${lib.makeBinPath [ bash pass-wayland fzf]}
''
