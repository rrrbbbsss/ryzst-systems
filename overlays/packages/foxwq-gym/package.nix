{ lib
, stdenv
, fetchzip
, autoPatchelfHook
, libGL
, xorg
, libpulseaudio
, makeDesktopItem
, eudev
}:

let
  pname = "foxwq-gym";
  version = "0.1";

  desktopItem = makeDesktopItem {
    name = pname;
    exec = "foxwq-gym";
    #icon = name;
    desktopName = "foxwq-gym";
    genericName = "foxwq-gym";
    categories = [ "Game" ];
    startupNotify = false;
  };

  libraries = lib.makeLibraryPath [
    libpulseaudio
    eudev
  ];
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchzip {
    url = "https://walruswq.com/file/foxwq_gym/foxwq-gym-v${version}-linux.zip";
    hash = "sha256-hYs1QYNNmJouhEVhqOlRi4HUQMZCm9M2u9kPhCTIl3Q=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    xorg.libXcursor
    xorg.libXinerama
    xorg.libXext
    xorg.libXrandr
    xorg.libXrender
    xorg.libX11
    xorg.libXi
    libGL
  ];

  installPhase = ''
    mkdir $out
    cp foxwq-gym.x86_64 foxwq-gym.pck $out

    mkdir $out/bin
    cat >$out/bin/foxwq-gym <<EOF
    #! ${stdenv.shell}
    export LD_LIBRARY_PATH="${libraries}"
    (cd $out; exec $out/foxwq-gym.x86_64 ; )
    EOF
    chmod +x $out/bin/foxwq-gym

    install -D ${desktopItem}/share/applications/${pname}.desktop \
            $out/share/applications/${pname}.desktop
  '';

  meta = with lib; {
    description = "Training application for solving tsumego";
    homepage = "https://walruswq.com/foxwq-gym";
    license = licenses.unfreeRedistributable;
    platforms = [ "x86_64-linux" ];
    mainProgram = "foxwq-gym";
  };
}
