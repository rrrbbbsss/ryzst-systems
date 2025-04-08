{ lib
, appimageTools
, fetchurl
}:

let
  pname = "weiqihub";
  version = "0.1.5";
  mainProgram = "weiqihub";
  src = fetchurl {
    name = "wqhub";
    url = "https://walruswq.com/file/WeiqiHub/WeiqiHub-${version}-x86_64.AppImage";
    hash = "sha256-NWQdSk/c9UwP7k5aeFYq2JbFUNBfmZqClZANXesehKQ=";
  };
  appimageContents = appimageTools.extract { inherit pname version src; };
in

appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: with pkgs; [
    libepoxy
    libopus
  ];

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/com.walruswq.wqhub.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/com.walruswq.wqhub.desktop \
      --replace-fail 'Exec=wqhub %u' 'Exec=${mainProgram}'
  '';

  meta = with lib; {
    description = "Unified client to multiple Go servers and offline puzzle solving";
    homepage = "https://walruswq.com/WeiqiHub";
    license = licenses.unfreeRedistributable;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    inherit mainProgram;
  };
}
