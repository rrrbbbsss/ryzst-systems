{ lib, runCommandLocal, makeWrapper, bash, fzf, nix, git, findutils }:
runCommandLocal "template-picker"
{
  script = ./script.sh;
  nativeBuildInputs = [ makeWrapper ];
} ''
  makeWrapper $script $out/bin/template-picker \
  --prefix PATH : ${lib.makeBinPath [ bash fzf nix git findutils ]}
''
