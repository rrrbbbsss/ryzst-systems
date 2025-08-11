# https://www.youtube.com/watch?v=xgG9wZPnf6k
{ lib
, fetchurl
, makeDesktopItem
, stdenvNoCC
, qemu
}:
let
  name = "tails";
  version = "6.14.2";

  src = fetchurl {
    url = "https://download.tails.net/tails/stable/tails-amd64-${version}/tails-amd64-${version}.iso";
    sha256 = "sha256-FWYwq/9RN6V3jtuG+EK2Rhbxq82oABJwImUevtBb2V4=";
  };

  desktopItem = makeDesktopItem {
    inherit name;
    exec = "${name}";
    desktopName = "Tails";
    genericName = "Tails";
    categories = [ "Network" ];
    startupNotify = false;
  };
in
stdenvNoCC.mkDerivation {
  inherit name version;

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin

    cat >$out/bin/tails <<EOF
    #! ${stdenvNoCC.shell}
    ${qemu}/bin/qemu-system-x86_64 \
        -enable-kvm \
        -cpu host \
        -smp cores=4 \
        -m 8G \
        -cdrom ${src} \
        -device intel-hda -audiodev pipewire,id=snd0 \
        -device hda-output,audiodev=snd0 \
        -device virtio-vga-gl \
        -display sdl,gl=on
    EOF
    chmod +x $out/bin/tails

    install -D ${desktopItem}/share/applications/${name}.desktop $out/share/applications/${name}.desktop
  '';

  meta = with lib; {
    description = "Portable operating system that protects your privacy and helps you avoid censorship";
    homepage = "https://tails.net/index.en.html";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = "tails";
  };
}
