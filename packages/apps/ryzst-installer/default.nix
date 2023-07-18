{ lib, runCommandLocal, makeWrapper, bash, fzf, coreutils-full, util-linux, gawk, ryzst }:
runCommandLocal "ryzst-installer"
{
  script = ./script.sh;
  nativeBuildInputs = [ makeWrapper ];
} ''
  makeWrapper $script $out/bin/ryzst-installer \
  --prefix PATH : ${lib.makeBinPath [bash fzf coreutils-full util-linux gawk ryzst.fzf-wifi]}
''
