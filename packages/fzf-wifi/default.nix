{ lib, runCommandLocal, makeWrapper, bash, networkmanager, fzf, ncurses }:
runCommandLocal "fzf-wifi"
{
  script = ./fzf-wifi.sh;
  nativeBuildInputs = [ makeWrapper ];
} ''
  makeWrapper $script $out/bin/fzf-wifi \
  --prefix PATH : ${lib.makeBinPath [ bash networkmanager fzf ncurses ]}
''
