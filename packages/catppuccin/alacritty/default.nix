{ stdenvNoCC, lib, fetchFromGitHub, ... }:

let
  owner = "catppuccin";
  repo = "alacritty";
  pname = "${owner}-${repo}";
  version = "2022-09-26";
  rev = "3c808cbb4f9c87be43ba5241bc57373c793d2f17";
in

stdenvNoCC.mkDerivation {
  inherit pname version;
  src = fetchFromGitHub {
    inherit owner rev repo;
    sha256 = "sha256-w9XVtEe7TqzxxGUCDUR9BFkzLZjG8XrplXJ3lX6f+x0=";
  };
  strictDeps = true;
  dontBuild = true;

  installPhase = ''
    mkdir $out
    cp *.yml $out 
  '';

  meta = with lib; {
    description = "catppuccin color scheme for alacritty";
    homepage = "https://github.com/catppuccin/alacritty";
    license = licenses.mit;
  };
}
