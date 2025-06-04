{ lib
, fetchFromGitHub
, stdenvNoCC
, makeWrapper
, bc
, sox
, coreutils-full
, gnugrep
, gnused
}:
let
  name = "lirc_rawcode2wav";
in
stdenvNoCC.mkDerivation {
  inherit name;
  src = fetchFromGitHub {
    owner = "S-shangli";
    repo = "lirc_rawcode2wav";
    rev = "1c47b2d310b7bf32e363c8def19e12c01b62726c";
    hash = "sha256-oP69W0VaPQFbjNpPgqi1xeb21P7rvdjp0kogNnoFZy4=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  dontUnpack = true;

  postPatch = ''
    cp $src/rawcode2wav.sh .

    substituteInPlace rawcode2wav.sh \
      --replace 'SOX_CMD=`which sox`' \
                'SOX_CMD=${sox}/bin/sox'

    substituteInPlace rawcode2wav.sh \
      --replace 'SOX_OPT="''${SOX_OPT} synth ''${LEN}s sine 19k 0 0 sine 19k 0 50"' \
                'SOX_OPT="''${SOX_OPT} synth ''${LEN}s trapezium 19k 0 0 trapezium 19k 0 50"'
  '';

  installPhase = ''
    install -D rawcode2wav.sh $out/bin/lirc_rawcode2wav
  '';

  postFixup = ''
    wrapProgram $out/bin/lirc_rawcode2wav --set PATH ${lib.makeBinPath [
      bc
      sox
      coreutils-full
      gnugrep
      gnused
    ]}
  '';

  meta = with lib; {
    description = "convert to wav file from the rawcode of mode2 command(lirc)";
    homepage = "https://github.com/S-shangli/lirc_rawcode2wav/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = name;
  };
}
