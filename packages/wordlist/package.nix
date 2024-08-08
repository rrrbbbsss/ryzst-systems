{ stdenvNoCC, aspellWithDicts, ... }:

let
  pname = "wordlist";
  version = "0.0.1";
  aspell = aspellWithDicts (dicts: with dicts; [ en ]);
in

stdenvNoCC.mkDerivation {
  inherit pname version;
  phases = [ "installPhase" ];
  buildInputs = [
    aspell
  ];
  installPhase = ''
    ${aspell}/bin/aspell dump master > $out
  '';
  meta = {
    description = "Wordlist of apsell dictionary";
  };
}
