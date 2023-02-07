{ stdenv, coreutils, fzf, ... }:
stdenv.mkDerivation {
  pname = "ryzst-cli";
  version = "0.0.1";
  src = ../../cli;
  propagatedBuildInputs = [ coreutils fzf ];
  installPhase = ''
    mkdir -p $out  $out/share/zsh/site-functions
    cp -r $src/bin $out
    cp -r $src/commands $out
  '';
}
