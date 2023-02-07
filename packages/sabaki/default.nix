{ lib, stdenv, makeDesktopItem, appimageTools, fetchurl }:

let
  version = "0.52.2";
  pname = "sabaki";
  name = "${pname}-${version}";
  src = fetchurl {
    url = "https://github.com/SabakiHQ/Sabaki/releases/download/v${version}/sabaki-v${version}-linux-x64.AppImage";
    sha256 = "0inlp5wb8719qygcac5268afim54ds7knffp765csrfdggja7q62";
  };
  appimageContents = appimageTools.extract { inherit name src; };
in
appimageTools.wrapType2 {
  inherit name src;

  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/${pname}
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
  };
}
