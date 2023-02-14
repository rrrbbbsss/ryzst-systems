{ lib, runCommandLocal, makeWrapper, bash, networkmanager, fzf }:
runCommandLocal "fzf-wifi" {
  script = ./fzf-wifi.sh;
  nativeBuildInputs = [ makeWrapper ];
} ''
  makeWrapper $script $out/bin/fzf-wifi \
  --prefix PATH : ${lib.makeBinPath [ bash networkmanager fzf]}
''
