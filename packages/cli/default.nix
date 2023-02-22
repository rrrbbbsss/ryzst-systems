{ lib
, runCommandLocal
, makeWrapper
, bash
, coreutils
, networkmanager
, fzf
, ryzst
, util-linux
, qemu
}:

runCommandLocal "ryzst-cli"
{
  src = ../../cli;
  nativeBuildInputs = [ makeWrapper ];
  meta = {
    mainProgram = "ryzst";
  };
} ''
  mkdir -p $out
  cp -r $src/commands $out
  makeWrapper $src/bin/ryzst $out/bin/ryzst \
  --prefix PATH : ${lib.makeBinPath [ 
    bash coreutils networkmanager fzf ryzst.fzf-wifi util-linux qemu
    ]}
''
