{ lib, runCommandLocal, makeWrapper, bash, fzf, coreutils-full, util-linux, gawk }:
runCommandLocal "burn-iso"
{
  script = ./script.sh;
  nativeBuildInputs = [ makeWrapper ];
} ''
  makeWrapper $script $out/bin/burn-iso \
  --prefix PATH : ${lib.makeBinPath [ bash fzf coreutils-full util-linux gawk ]}
''
