{ lib
, makeDesktopItem
, iconConvTools
, python3Packages
, katago
, ryzst
, fetchFromGitHub
, gst_all_1
}:

let
  pname = "katrain";
  version = "1.16";
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
  pyproject = true;

  src = fetchFromGitHub {
    owner = "sanderland";
    repo = "katrain";
    rev = "v${version}";
    hash = "sha256-v0VGjxayXLbBSXs/jkYeXgbyDg+JFLgxESDuh/qbg1U=";
  };

  nativeBuildInputs = [
    iconConvTools
    pythonPackages.poetry-core
    pythonPackages.poetry-dynamic-versioning
  ];

  propagatedBuildInputs = with pythonPackages; [
    certifi
    chardet
    docutils
    #ryzst.ffpyplayer
    idna
    kivy
    kivy-garden
    ryzst.kivymd
    pillow
    pygments
    requests
    urllib3
    screeninfo
  ];

  postPatch = ''
    substituteInPlace katrain/core/engine.py \
      --replace 'katrain/KataGo/katago' ${katago}/bin/katago

    sed -i 's/^ranking.*/ranking = [ ("gst", -10), ("", 0) ]/' katrain/gui/sound.py

    sed -i 's/^ffpyplayer/#ffpyplayer/' pyproject.toml
  '';

  postFixup =
    let
      GST_PLUGIN_PATH = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" [
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
      ];
    in
    ''
      wrapProgram $out/bin/katrain --prefix GST_PLUGIN_PATH : ${GST_PLUGIN_PATH}
    '';


  postInstall = ''
    install -D ${desktopItem}/share/applications/${pname}.desktop $out/share/applications/${pname}.desktop
    icoFileToHiColorTheme katrain/img/icon.ico katrain $out
  '';

  # TODO: try to get tests working...
  doCheck = false;

  meta = {
    homepage = "https://github.com/sanderland/katrain";
    description = "tool for analyzing games and playing go with AI feedback from KataGo";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "katrain";
  };
}


