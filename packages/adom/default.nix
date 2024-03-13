{ lib
, ncurses5
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  #https://aur.archlinux.org/packages/adom#comment-839146
  fix-ncurses = ncurses5.overrideAttrs (old: {
    configureFlags = lib.remove
      "--with-versioned-syms"
      old.configureFlags;
  });
in
stdenv.mkDerivation rec {
  name = "adom-${version}";
  version = "3.3.3";

  src = fetchurl {
    url = "https://www.adom.de/home/download/current/adom_linux_ubuntu_64_${version}.tar.gz";
    sha256 = "sha256-ST73ZZTB9qfzjc8yp2zRB/tx3RK/kXwY/errysGjU7E=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    fix-ncurses
  ];

  installPhase = ''
    install -m755 -D adom $out/bin/adom
  '';

  meta = with lib; {
    description = "A rogue-like game with nice graphical interface";
    homepage = "http://adom.de/";
    license = licenses.unfreeRedistributable;
    platforms = [ "x86_64-linux" ];
  };
}
