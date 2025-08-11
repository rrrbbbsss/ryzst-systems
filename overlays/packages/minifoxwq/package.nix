{ lib
, stdenv
, fetchzip
, autoPatchelfHook
, libGL
, xorg
, libpng
, libgcc
, makeDesktopItem
}:

let
  pname = "minifoxwq";
  version = "0.14";

  desktopItem = makeDesktopItem {
    name = pname;
    exec = "minifox";
    #icon = name;
    desktopName = "MiniFoxWQ";
    genericName = "MiniFoxWQ";
    categories = [ "Game" ];
    startupNotify = false;
  };

in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchzip {
    url = "https://github.com/openfoxwq/openfoxwq.github.io/releases/download/v${version}/minifox-v${version}-linux.zip";
    hash = "sha256-GWGyETaxCCcSKddgvhum8lqY7sQuufyWV5YyLCj1o1o=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    libGL
    xorg.libX11
    libpng
    libgcc.lib
  ];

  installPhase = ''
    mkdir $out
    cp -r minifox asset $out

    mkdir $out/bin
    cat >$out/bin/minifox <<EOF
    #! ${stdenv.shell}
    export MINIFOXWQ_DATA_DIR=\''${HOME}/.cache/minifoxwq
    (cd $out; exec $out/minifox ; )
    EOF
    chmod +x $out/bin/minifox

    install -D ${desktopItem}/share/applications/${pname}.desktop $out/share/applications/${pname}.desktop
  '';

  meta = with lib; {
    description = "Third-party unofficial client for the Fox Go Server";
    homepage = "https://openfoxwq.github.io/";
    license = licenses.unfreeRedistributable;
    platforms = [ "x86_64-linux" ];
    mainProgram = "minifox";
  };
}
