{ config, pkgs, home-manager, lib, ... }:

{
  # BootLoader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true; # change this to false
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.tmpOnTmpfs = true;
  boot.kernelParams = [ "console=tty1" ];

  # Networking
  networking.hostName = builtins.baseNameOf ./.;

  # VMS
  virtualisation.libvirtd = {
    enable = true;
    qemu.runAsRoot = false;
    onShutdown = "shutdown";
  };

  # NFS
  services.rpcbind.enable = true;
  systemd.mounts = [{
    type = "nfs";
    mountConfig = {
      Options = "noatime";
    };
    what = "nfs.int.ryzst.net:/";
    where = "/nfs";
  }];
  systemd.automounts = [{
    wantedBy = [ "multi-user.target" ];
    automountConfig = {
      TimeoutIdleSec = "600";
    };
    where = "/nfs";
  }];
  environment.systemPackages = with pkgs; [
    nfs-utils
  ];

  # Printer
  services.printing = {
    enable = true;
  };
}