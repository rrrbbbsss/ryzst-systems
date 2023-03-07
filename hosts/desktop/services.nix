{ config, pkgs, home-manager, lib, ... }:

{
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
