{ stdenvNoCC, lib, fetchurl, ... }:

let
  pname = "katago-model";
  version = "kata1-b40c256-s11840935168-d2898845681";
  name = "${pname}-${version}.bin.gz";
in

stdenvNoCC.mkDerivation {
  inherit pname version name;
  src = fetchurl {
    url = "https://media.katagotraining.org/uploaded/networks/models/kata1/kata1-b40c256-s11840935168-d2898845681.bin.gz";
    sha256 = "4179c907f5e8850ff3fa9d1d2d4e590ef7d1643ab4d4bd7324e6519c8d0562bc";
  };
  phases = [ "installPhase" ];
  installPhase = ''
    cp $src $out
  '';
  meta = with lib; {
    description = "Network model for Katago";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    #license = https://katagotraining.org/network_license/
  };
}
