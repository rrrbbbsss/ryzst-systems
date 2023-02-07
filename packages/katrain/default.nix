{ lib
, makeDesktopItem
, iconConvTools
, python3Packages
, katago
, ryzst
}:

let
  pname = "katrain";
  version = "1.12.3";
  pythonPackages = python3Packages;
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
pythonPackages.buildPythonApplication {
  inherit pname version;

  src = pythonPackages.fetchPypi {
    pname = "KaTrain";
    inherit version;
    sha256 = "sha256-Mnv6Ij3hEXiPr/ru94MZioWea7Gza13IwAbI0pNOGpE=";
  };

  nativeBuildInputs = [ iconConvTools ];

  propagatedBuildInputs = with pythonPackages; [
    certifi
    chardet
    docutils
    ryzst.python-libs.ffpyplayer
    idna
    ryzst.python-libs.kivy
    kivy-garden
    ryzst.python-libs.kivymd
    pillow
    pygments
    requests
    urllib3
    screeninfo
  ];

  postPatch = ''
    substituteInPlace katrain/core/engine.py \
      --replace 'katrain/KataGo/katago' ${katago}/bin/katago
  '';

  postInstall = ''
    install -D ${desktopItem}/share/applications/${pname}.desktop $out/share/applications/${pname}.desktop
    icoFileToHiColorTheme katrain/img/icon.ico katrain $out
  '';

  #todo: try to get tests working...
  doCheck = false;

  meta = {
    homepage = "https://github.com/sanderland/katrain";
    description = "KaTrain is a tool for analyzing games and playing go with AI feedback from KataGo";
    longDescription = ''
      KaTrain is a tool for analyzing games and playing go with AI feedback from KataGo:
      - Review your games to find the moves that were most costly in terms of points lost.
      - Play against AI and get immediate feedback on mistakes with option to retry.
      - Play against a wide range of weakened versions of AI with various styles.
      - Automatically generate focused SGF reviews which show your biggest mistakes.
    '';
    license = licenses.mit;
  };
}
