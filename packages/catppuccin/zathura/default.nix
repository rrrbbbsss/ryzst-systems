{ stdenvNoCC, lib, fetchFromGitHub, ... }:

let
  owner = "catppuccin";
  repo = "zathura";
  pname = "${owner}-${repo}";
  version = "2022-09-26";
  rev = "d85d8750acd0b0247aa10e0653998180391110a4";
in

stdenvNoCC.mkDerivation {
  inherit pname version;
  src = fetchFromGitHub {
    inherit owner rev repo;
    sha256 = "sha256-5Vh2bVabuBluVCJm9vfdnjnk32CtsK7wGIWM5+XnacM=";
  };
  strictDeps = true;
  dontBuild = true;

  installPhase = ''
    cp -r $src/src $out
  '';

  meta = with lib; {
    description = "catppuccin color scheme for zathura";
    homepage = "https://github.com/catppuccin/zathura";
    license = licenses.mit;
  };
}