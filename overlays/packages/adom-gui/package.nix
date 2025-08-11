{ lib
, ncurses5
, stdenv
, autoPatchelfHook
, curl
, SDL2
, SDL2_mixer
, SDL2_image
, SDL2_net
, SDL2_ttf
, libmad
, libpng12
, libGLU
, luajit
, requireFile
, makeDesktopItem
}:

let
  name = "adom-gui";
  version = "3.3.3";
  #https://aur.archlinux.org/packages/adom#comment-839146
  fix-ncurses = ncurses5.overrideAttrs (old: {
    configureFlags = lib.remove
      "--with-versioned-syms"
      old.configureFlags;
  });

  desktopItem = makeDesktopItem {
    inherit name;
    exec = "${name} %F";
    #icon = name;
    desktopName = "Adom";
    genericName = "Adom";
    categories = [ "Game" ];
    startupNotify = false;
  };
in
stdenv.mkDerivation {
  inherit name version;

  src = requireFile {
    name = "adom_noteye_linux_debian_64_3.3.3.tar.gz";
    url = "https://www.indiedb.com/downloads/start/173930";
    sha256 = "sha256-XOw5PdldsUu8wOXfSzMAne//fDpOt1Vx15BqFM5Zjfk=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    fix-ncurses
    curl
    SDL2
    SDL2_mixer
    SDL2_image
    SDL2_net
    SDL2_ttf
    libmad
    libpng12
    libGLU
    luajit
  ];

  installPhase = ''
    mkdir $out
    cp -r adom cabundle.pem common docs games gfx lib/libnoteye.so licenses sound $out

    mkdir $out/bin
    cat >$out/bin/adom-gui <<EOF
    #! ${stdenv.shell}
    (cd $out; exec $out/adom ; )
    EOF
    chmod +x $out/bin/adom-gui

    install -D ${desktopItem}/share/applications/${name}.desktop $out/share/applications/${name}.desktop
  '';

  meta = with lib; {
    description = "A rogue-like game with nice graphical interface";
    homepage = "http://adom.de/";
    license = licenses.unfreeRedistributable;
    platforms = [ "x86_64-linux" ];
  };
}
