{ lib
, stdenv
, fetchurl
, openjdk11
, makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "souffle-lsp-plugin";
  version = "0.3.8";
  src = fetchurl {
    url = "https://github.com/jdaridis/souffle-lsp-plugin/releases/download/v${version}/Souffle_Ide_Plugin-1.0-SNAPSHOT.jar";
    hash = "sha256-Dg6IPbohznTtepmAY4GipnY685gb7z9dhI/t/1yVt84=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/lib
    mkdir -p $out/bin

    install -D $src $out/lib/souffle-lsp-plugin.jar
    makeWrapper ${openjdk11}/bin/java $out/bin/souffle-lsp-plugin \
      --set JAVA_HOME ${openjdk11} \
      --add-flags "-jar $out/lib/souffle-lsp-plugin.jar"
  '';

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ openjdk11 ];

  meta = {
    description = "souffle language server";
    homepage = "https://github.com/jdaridis/souffle-lsp-plugin";
    changelog = "https://github.com/jdaridis/souffle-lsp-plugin/blob/${version}/CHANGELOG.md";
    # TODO: fix
    #license = lib.licenses.unfree;
    platforms = lib.platforms.unix;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
  };
}
