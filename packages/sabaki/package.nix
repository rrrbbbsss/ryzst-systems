{ lib, appimageTools, fetchurl }:

let
  version = "0.52.2";
  pname = "sabaki";
  src = fetchurl {
    url = "https://github.com/SabakiHQ/Sabaki/releases/download/v${version}/sabaki-v${version}-linux-x64.AppImage";
    hash = "sha256-wuCj5HvNZc2KOdc5O49upNToFDKiMMWexykctHi51EY=";
  };
  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: with pkgs; [
    xorg.libxshmfence
  ];

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun --no-sandbox %U' 'Exec=${pname} %U'
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  meta = with lib; {
    # note: if you use wayland(sway) and sabaki crashes: disable hardware acceleration in settings
    description = "An elegant Go board and SGF editor for a more civilized age.";
    homepage = "https://sabaki.yichuanshen.de/";
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "sabaki";
  };
}
