{ lib
, buildPythonPackage
, fetchPypi
, cython, pkg-config, pytest
, SDL2, SDL2_mixer, ffmpeg
}:

let
  pname = "ffpyplayer";
  version = "4.3.2";
in

buildPythonPackage rec {
  inherit pname version;
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-DnrxcejY+XviGASEYeiMTGRJPSvQBouINcBcsxNhSto=";
  };

  nativeBuildInputs = [ cython pkg-config pytest ];
  buildInputs = [ SDL2 SDL2_mixer ffmpeg ];

  preBuild = ''
    export USE_SDL_MIXER="1"
  '';

  pythonImportsCheck = [ "ffpyplayer" ];

  meta = with lib; {
    description = "FFPyPlayer is a python binding for the FFmpeg library for playing and writing media files.";
    homepage = "https://matham.github.io/ffpyplayer/";
    license = licenses.lgpl3;
  };
}
