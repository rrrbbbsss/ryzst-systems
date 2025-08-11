{ pkgs, ... }:

with pkgs;
let
  ryzst = callPackage ./ryzst { };
  ryzst-installer = callPackage ./ryzst-installer { };
  burn-iso = callPackage ./burn-iso { };
  yubikey-setup = callPackage ./yubikey-setup { };
in

runCommandLocal "ryzst-apps"
{ inherit ryzst burn-iso ryzst-installer yubikey-setup; } ''
  mkdir -p $out/bin
  cp ${ryzst}/bin/ryzst $out/bin
  cp ${burn-iso}/bin/burn-iso $out/bin
  cp ${ryzst-installer}/bin/ryzst-installer $out/bin
  cp ${yubikey-setup}/bin/yubikey-setup $out/bin
''
