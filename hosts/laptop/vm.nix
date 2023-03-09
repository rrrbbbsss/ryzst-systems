{ modulesPath, ... }:

{
  imports = [
    ../../modules/profiles/vm.nix 
    ../../modules/hardware/devices/yubico/yubikey5
  ];
}