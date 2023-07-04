{ lib, runCommand, makeWrapper, bash, jq, fzf, pandoc, wl-clipboard, hm }:
runCommand "fzf-nix-options"
{
  script = ./script.sh;
  nativeBuildInputs = [ makeWrapper ];
} ''
  makeWrapper $script $out/bin/fzf-nix-options \
  --prefix PATH : ${lib.makeBinPath [ bash fzf jq pandoc wl-clipboard ]} \
  --set HOME_OPTIONS ${hm.docs-json}/share/doc/home-manager/options.json \
  --set NIXOS_OPTIONS "todo"
''
