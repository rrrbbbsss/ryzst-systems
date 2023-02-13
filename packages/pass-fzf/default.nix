{ lib, runCommandLocal, makeWrapper, bash, pass-wayland, fzf }:
runCommandLocal "pass-fzf" {
  script = ./pass-fzf.sh;
  nativeBuildInputs = [ makeWrapper ];
} ''
  makeWrapper $script $out/bin/pass-fzf \
  --prefix PATH : ${lib.makeBinPath [ bash pass-wayland fzf]}
''
