{ lib
, buildPythonPackage
, fetchPypi
, requests
, docutils
, kivy
}:

let
  pname = "kivymd";
  version = "0.104.1";
in

buildPythonPackage rec {
  inherit pname version;
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ncvCy4r/3pyCVyGY/dsyyBTN1XJUoOSwDFOILbLI1qY=";
  };

  nativeBuildInputs = [ docutils ];
  propagatedBuildInputs = [ requests kivy ];

  doCheck = false;
  # create ./.kivy for import test
  postInstall = ''
    export HOME=$(pwd)
  '';
  pythonImportsCheck = [ "kivymd" ];

  meta = with lib; {
    description = "KivyMD is a collection of Material Design compliant widgets for use with Kivy";
    homepage = "https://github.com/kivymd/KivyMD";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
