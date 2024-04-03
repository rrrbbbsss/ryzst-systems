{ buildPythonApplication
, setuptools
, gobject-introspection
, wrapGAppsHook
, gtk4
, pygobject3
}:

buildPythonApplication {
  name = "media-powermenu";
  src = ./.;
  version = "0.0.1";
  pyproject = true;

  nativeBuildInputs = [
    setuptools
    gobject-introspection
    wrapGAppsHook
  ];

  buildInputs = [
    gtk4
  ];

  propagatedBuildInputs = [
    pygobject3
  ];

  postInstall = ''
    install -D $src/icons/power.png $out/share/icons/power.png
  '';

  meta = {
    description = "A simple powermenu";
    platforms = [ "x86_64-linux" ];
    mainProgram = "media-powermenu";
  };
}

