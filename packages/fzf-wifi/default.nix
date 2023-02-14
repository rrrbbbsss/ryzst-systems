{ lib, runCommandLocal, makeWrapper, bash, pass-wayland, fzf }:
runCommandLocal "fzf-wifi" {
  script = ./fzf-wifi.sh;
  nativeBuildInputs = [ makeWrapper ];
} ''
  makeWrapper $script $out/bin/fzf-wifi \
  --prefix PATH : ${lib.makeBinPath [ bash pass-wayland fzf]}
''
