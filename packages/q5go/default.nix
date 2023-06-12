{ lib
, stdenv
, fetchFromGitHub
, makeDesktopItem
, pkg-config
, iconConvTools
, wrapQtAppsHook
, qmake
, qtbase
, qtmultimedia
}:

let
  pname = "q5go";
  version = "2.1.3";
  desktopItem = makeDesktopItem {
    name = pname;
    exec = "${pname} %F";
    icon = pname;
    desktopName = pname;
    genericName = pname;
    categories = [ "Game" ];
    startupNotify = false;
  };
in

with lib;
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "bernds";
    repo = "q5Go";
    rev = "${pname}-${version}";
    sha256 = "sha256-MQ/FqAsBnQVaP9VDbFfEbg5ymteb/NSX4nS8YG49HXU=";
  };

  nativeBuildInputs = [
    pkg-config
    iconConvTools
    wrapQtAppsHook
    qmake
  ];

  buildInputs = [
    qtbase
    qtmultimedia
  ];

  qmakeFlags = [
    "src/q5go.pro"
  ];

  postInstall = ''
    install -D ${desktopItem}/share/applications/${pname}.desktop $out/share/applications/${pname}.desktop
    icoFileToHiColorTheme src/images/Bowl.ico ${pname} $out
  '';

  meta = {
    homepage = "https://github.com/bernds/q5Go";
    description = "A tool for Go players for editing sgf files and analyzing games";
    longDescription = ''
      This is a tool for Go players which performs the following functions:
      - SGF editor
      - Analysis frontend for KataGo, Leela Zero or compatible engines
      - Pattern search and game info search in a database
      - GTP interface
      - IGS client
      - Export to a variety of formats
    '';
    license = licenses.gpl2;
  };
}
