{ modulesPath, ... }:

{
  imports = [ 
    (modulesPath + "/virtualisation/qemu-vm.nix")
    ../../modules/profiles/vm.nix 
  ];
}