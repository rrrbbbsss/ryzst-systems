{ lib
, fetchurl
, makeDesktopItem
, stdenvNoCC
, unzip
, winetricks
, wineWowPackages
}:
let
  name = "cho-ren-sha-68k";
  version = "1.10.15";
  src = fetchurl {
    url = "https://github.com/yosshin4004/yosshin4004.github.io/releases/download/crs68k_110/crs68k_110_build20250119_wip15.zip";
    hash = "sha256-SrfkoXZXOlhcA8y/7iF5KmsbpEBkQhm5ughgZ7wq8Eo=";
  };
  desktopItem = makeDesktopItem {
    inherit name;
    exec = name;
    desktopName = name;
    genericName = name;
    categories = [ "Game" ];
    startupNotify = false;
  };
in
stdenvNoCC.mkDerivation
{
  inherit name version;

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin

    cat >$out/bin/${name} <<'EOF'
    #! ${stdenvNoCC.shell}

    DUMP_DIR="$HOME/.crs68k-${version}"
    export WINEPREFIX="$DUMP_DIR/wine"
    if [[ ! -d "$DUMP_DIR" ]]; then
      ${unzip}/bin/unzip ${src} -d "$DUMP_DIR"
      ${winetricks}/bin/winetricks vkd3d
      ${winetricks}/bin/winetricks dxvk
    fi
    ${wineWowPackages.full}/bin/wine "$DUMP_DIR/crs68k/cho_ren_sha_68k.exe"

    EOF
    chmod +x $out/bin/${name}

    install -D ${desktopItem}/share/applications/${name}.desktop $out/share/applications/${name}.desktop
  '';

  meta = with lib; {
    description = "1995 vertically scrolling doujin shoot'em up video game";
    homepage = "https://yosshin4004.github.io/x68k/crs68k/official/index.html";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = name;
  };
}
