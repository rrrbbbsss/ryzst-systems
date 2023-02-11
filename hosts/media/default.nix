{ config, pkgs, lib, ... }:

{
  # BootLoader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.tmpOnTmpfs = true;
  boot.kernelParams = [ "console=tty1" ];

  users.mutableUsers = false;
  users.users.root.initialPassword = "*";

  networking.hostName = builtins.baseNameOf ./.;
}
